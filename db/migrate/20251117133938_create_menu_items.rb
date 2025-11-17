class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.string :name
      t.string :size
      t.decimal :price, precision: 10, scale: 2
      t.string :image
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
