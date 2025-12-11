class User < ApplicationRecord
  has_many :orders
  has_many :cart_items, dependent: :destroy
  has_secure_password validations: false

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
                    length: { maximum: 255 }
  validates :name, presence: true,
                   length: { minimum: 2, maximum: 50 }
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
  def self.from_google_oauth(google_user_info)
    provider = "google"
    uid = google_user_info["id"]
    email = google_user_info["email"]

    # First, try to find user by provider and uid (existing Google OAuth user)
    user = where(provider: provider, uid: uid).first

    # If not found, check if user exists with this email (regular signup)
    if user.nil?
      user = find_by(email: email)

      if user
        # Link existing account to Google OAuth
        user.provider = provider
        user.uid = uid
      else
        # Create new user
        user = new(
          email: email,
          name: google_user_info["name"] || email.split("@").first,
          password: SecureRandom.hex(32),
          role: "customer",
          provider: provider,
          uid: uid
        )
      end
    end

    # Update OAuth token info on every login
    user.oauth_token = google_user_info["access_token"]
    user.oauth_expires_at = google_user_info["expires_at"] ? Time.at(google_user_info["expires_at"].to_i) : nil

    user
  end

  def oauth_user?
    provider.present? && uid.present?
  end

  private

  def password_required?
    # Check both persisted and pending changes for OAuth status
    is_oauth = (provider.present? || provider_changed?) && (uid.present? || uid_changed?)
    !is_oauth && (password_digest.nil? || password.present?)
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
