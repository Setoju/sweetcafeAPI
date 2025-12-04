class User < ApplicationRecord
  has_many :orders
  has_many :cart_items, dependent: :destroy
  has_secure_password

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
  
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validates :password, length: { minimum: 8 }, allow_nil: true, on: :update
  
  validate :password_complexity
  
  before_validation :normalize_email
  
  private
  
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
