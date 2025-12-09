class ModifyMenuItemForeignKeyInOrderItems < ActiveRecord::Migration[8.0]
  def change
    # Make menu_item_id nullable
    change_column_null :order_items, :menu_item_id, true
    
    # Remove the existing foreign key constraint
    remove_foreign_key :order_items, :menu_items
    
    # Add a new foreign key constraint that sets to NULL when menu item is deleted
    add_foreign_key :order_items, :menu_items, on_delete: :nullify
  end
end
