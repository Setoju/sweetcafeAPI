class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :menu_item

  validates :total_quantity, presence: true,
                             numericality: { only_integer: true, greater_than: 0,
                                           message: "must be positive and greater than 0" }
  validates :user, presence: true
  validates :menu_item, presence: true
  validates :menu_item_id, uniqueness: { scope: :user_id, message: "is already in cart" }
  
  validate :menu_item_must_be_available
  validate :quantity_must_not_exceed_stock

  private

  def menu_item_must_be_available
    return unless menu_item.present?
    
    unless menu_item.available?
      errors.add(:menu_item, "is not available")
    end
  end

  def quantity_must_not_exceed_stock
    return unless menu_item.present? && total_quantity.present?
    
    if total_quantity > menu_item.quantity
      errors.add(:total_quantity, "exceeds available stock (#{menu_item.quantity} available)")
    end
  end
end
