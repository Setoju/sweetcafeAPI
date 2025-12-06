class AddFieldsToDeliveries < ActiveRecord::Migration[8.0]
  def change
    add_column :deliveries, :phone, :string
    add_column :deliveries, :delivery_status, :string, default: 'pending'
    add_column :deliveries, :delivered_at, :datetime

    # Rename notes to delivery_notes for consistency
    rename_column :deliveries, :notes, :delivery_notes if column_exists?(:deliveries, :notes)
  end
end
