class User < ApplicationRecord
  has_many :orders
  has_secure_password

  validates :email, presence: true, 
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
                    length: { maximum: 255 }
  validates :name, presence: true,
                   length: { minimum: 2, maximum: 100 },
                   format: { with: /\A[a-zA-Z\s'-]+\z/, message: "can only contain letters, spaces, hyphens, and apostrophes" }
  validates :phone, format: { with: /\A[+]?[0-9\s().-]{10,20}\z/, message: "must be a valid phone number" },
                    allow_blank: true,
                    length: { minimum: 10, maximum: 20 }
  validates :role, presence: true,
                   inclusion: { in: %w[customer admin staff], message: "%{value} is not a valid role" }
  
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? },
                       allow_nil: true
  
  before_validation :normalize_email
  
  private
  
  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end
end
