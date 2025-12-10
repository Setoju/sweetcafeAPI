class AddDiscountToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_column :menu_items, :discount, :integer, default: 0, null: false
  end
end
