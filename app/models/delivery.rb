class Delivery < ApplicationRecord
  belongs_to :order

  validates :address, presence: true,
                      length: { minimum: 2, maximum: 50 },
                      unless: -> { delivery_method == "pickup" }
  validates :city, presence: true,
                   length: { minimum: 2, maximum: 100 },
                   format: { with: /\A[a-zA-Z\s'-]+\z/, message: "can only contain letters, spaces, hyphens, and apostrophes" },
                   unless: -> { delivery_method == "pickup" }
  validates :phone, presence: true,
                    format: { with: /\A[+]?[0-9\s().-]{10,20}\z/, message: "must be a valid phone number" },
                    length: { minimum: 10, maximum: 20 }
  validates :delivery_method, inclusion: { in: [ "by courier", "pickup" ], message: "%{value} is not a valid delivery method" },
                            allow_blank: true
  validates :payment_method, inclusion: { in: %w[cash card online], message: "%{value} is not a valid payment method" },
                           allow_blank: true
  validates :delivery_status, presence: true,
                              inclusion: { in: %w[pending in_transit delivered], message: "%{value} is not a valid delivery status" }
  validates :delivery_notes, length: { maximum: 50 }, allow_blank: true
  validates :order, presence: true
  validate :delivery_time_is_future, on: :create, if: -> { delivery_time.present? }
  validate :pickup_time_is_future, on: :create, if: -> { pickup_time.present? }
  validate :delivered_at_when_delivered

  enum :delivery_status, { pending: "pending", in_transit: "in_transit", delivered: "delivered" }, default: :pending

  private

  def delivery_time_is_future
    if delivery_time < Time.current
      errors.add(:delivery_time, "must be in the future")
    end
  end

  def pickup_time_is_future
    if pickup_time < Time.current
      errors.add(:pickup_time, "must be in the future")
    end
  end

  def delivered_at_when_delivered
    if delivery_status == "delivered" && delivered_at.blank?
      errors.add(:delivered_at, "must be set when delivery status is delivered")
    end
  end
end
