class CreateDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :deliveries do |t|
      t.references :order, null: false, foreign_key: true
      t.string :delivery_type
      t.datetime :delivery_time
      t.string :city
      t.string :address
      t.string :payment_type
      t.string :notes

      t.timestamps
    end
  end
end
