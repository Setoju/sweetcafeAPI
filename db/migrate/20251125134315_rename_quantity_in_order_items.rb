class RenameQuantityInOrderItems < ActiveRecord::Migration[8.0]
  def change
    rename_column :order_items, :quantity, :total_quantity
  end
end
