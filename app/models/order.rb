class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_one :delivery, dependent: :destroy

  validates :status, presence: true,
                     inclusion: { in: %w[pending completed delivered cancelled], message: "%{value} is not a valid status" }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000000 },
                           allow_nil: true
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :user, presence: true
  validate :must_have_order_items, on: :update
  validate :total_amount_matches_items, if: -> { total_amount.present? && order_items.any? }
  
  enum :status, { pending: "pending", completed: "completed", delivered: "delivered", cancelled: "cancelled" }, default: :pending
  
  private
  
  def must_have_order_items
    if order_items.empty?
      errors.add(:base, "Order must have at least one item")
    end
  end
  
  def total_amount_matches_items
    calculated_total = order_items.sum(&:subtotal)
    if calculated_total.present? && (total_amount - calculated_total).abs > 0.01
      errors.add(:total_amount, "does not match the sum of order items (expected: #{calculated_total})")
    end
  end
end
