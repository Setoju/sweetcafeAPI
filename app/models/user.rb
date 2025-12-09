class User < ApplicationRecord
  has_many :orders
  has_many :cart_items, dependent: :destroy
  has_secure_password validations: false

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
                    length: { maximum: 255 }
  validates :name, presence: true,
                   length: { minimum: 2, maximum: 50 },
                   format: { with: /\A[a-zA-Z\s'-]+\z/, message: "can only contain letters, spaces, hyphens, and apostrophes" }
  validates :phone, format: { with: /\A[+]?[0-9\s().-]{10,20}\z/, message: "must be a valid phone number" },
                    allow_blank: true,
                    length: { minimum: 10, maximum: 20 }
  validates :role, presence: true,
                   inclusion: { in: %w[customer admin staff], message: "%{value} is not a valid role" }

  # Password validations only for non-OAuth users
  validates :password, presence: true, length: { minimum: 8 }, on: :create, if: :password_required?
  validates :password, length: { minimum: 8 }, allow_nil: true, on: :update, if: :password_required?

  validate :password_complexity, if: :password_required?

  before_validation :normalize_email

  # OAuth methods
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) if auth.credentials.expires_at
      user.password = SecureRandom.hex(20) # Set random password for OAuth users
      user.role = "customer" # Default role for OAuth users
    end
  end

  def oauth_user?
    provider.present? && uid.present?
  end

  private

  def password_required?
    !oauth_user? && (password_digest.nil? || password.present?)
  end

  def password_complexity
    return if password.blank?

    errors.add(:password, "must include at least one uppercase letter") unless password.match?(/[A-Z]/)
    errors.add(:password, "must include at least one lowercase letter") unless password.match?(/[a-z]/)
    errors.add(:password, "must include at least one number") unless password.match?(/[0-9]/)
    errors.add(:password, "must include at least one special character") unless password.match?(/[^A-Za-z0-9]/)
  end

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end
end
