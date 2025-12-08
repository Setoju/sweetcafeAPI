class RenameQuantityToAvailableQuantityInMenuItems < ActiveRecord::Migration[8.0]
  def change
    rename_column :menu_items, :quantity, :available_quantity
  end
end
