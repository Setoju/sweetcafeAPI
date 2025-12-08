module InventoryValidator
  extend ActiveSupport::Concern

  private

  def validate_inventory_availability(menu_item, requested_quantity)
    return { valid: false, error: "Menu item not found" } unless menu_item

    unless menu_item.available?
      return { valid: false, error: "#{menu_item.name} is currently unavailable" }
    end

    if requested_quantity > menu_item.quantity
      return { 
        valid: false, 
        error: "#{menu_item.name}: only #{menu_item.quantity} available, but #{requested_quantity} requested" 
      }
    end

    { valid: true }
  end

  def validate_multiple_items_inventory(order_items_params)
    errors = []

    order_items_params.each do |item_params|
      menu_item = MenuItem.find_by(id: item_params[:menu_item_id])
      requested_quantity = item_params[:total_quantity].to_i

      validation_result = validate_inventory_availability(menu_item, requested_quantity)
      
      unless validation_result[:valid]
        errors << validation_result[:error]
      end
    end

    errors
  end
end