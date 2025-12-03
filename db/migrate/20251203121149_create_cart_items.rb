class CreateCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.integer :total_quantity, null: false, default: 1

      t.timestamps
    end
    
    add_index :cart_items, [:user_id, :menu_item_id], unique: true
  end
end
