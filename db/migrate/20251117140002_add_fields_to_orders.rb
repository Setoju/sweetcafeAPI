class AddFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :notes, :text

    # Rename total_price to total_amount for consistency
    rename_column :orders, :total_price, :total_amount if column_exists?(:orders, :total_price)

    # Remove total_items as it can be calculated
    remove_column :orders, :total_items, :integer if column_exists?(:orders, :total_items)
  end
end
