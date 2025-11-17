class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, null: false, index: { unique: true }
      t.string :phone
      t.string :password_digest
      t.string :role, default: 'customer'

      t.timestamps
    end
  end
end
