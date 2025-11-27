class AddFieldsToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_column :menu_items, :description, :text
    add_column :menu_items, :available, :boolean, default: true
    add_column :menu_items, :image_url, :string
    add_column :menu_items, :quantity, :integer, default: 0, null: false
    
    rename_column :menu_items, :image, :old_image if column_exists?(:menu_items, :image)
    remove_column :menu_items, :old_image, :string if column_exists?(:menu_items, :old_image)
  end
end
