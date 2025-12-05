class AddPickupTimeToDeliveries < ActiveRecord::Migration[8.0]
  def change
    add_column :deliveries, :pickup_time, :datetime
  end
end
