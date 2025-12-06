class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :menu_item

  validates :total_quantity, presence: true,
                       numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100, message: "must be between 1 and 100" }
  validates :price, presence: true,
                    numericality: { greater_than: 0, less_than_or_equal_to: 10000, message: "must be between 0 and 10,000" }
  validates :subtotal, numericality: { greater_than: 0, less_than_or_equal_to: 1000000 },
                       allow_nil: true
  validates :order, presence: true
  validates :menu_item, presence: true
  validate :subtotal_matches_calculation, if: -> { subtotal.present? && price.present? && total_quantity.present? }

  before_save :calculate_subtotal

  private

  def calculate_subtotal
    self.subtotal = price * total_quantity if price.present? && total_quantity.present?
  end

  def subtotal_matches_calculation
    calculated_subtotal = price * total_quantity
    if (subtotal - calculated_subtotal).abs > 0.01
      errors.add(:subtotal, "does not match price × quantity (expected: #{calculated_subtotal})")
    end
  end
end
