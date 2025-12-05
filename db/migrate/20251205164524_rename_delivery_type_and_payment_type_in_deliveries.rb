class RenameDeliveryTypeAndPaymentTypeInDeliveries < ActiveRecord::Migration[8.0]
  def change
    rename_column :deliveries, :delivery_type, :delivery_method
    rename_column :deliveries, :payment_type, :payment_method
  end
end
