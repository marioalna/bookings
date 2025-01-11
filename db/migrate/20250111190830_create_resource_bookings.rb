class CreateResourceBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :resource_bookings do |t|
      t.references :resource
      t.references :booking
      t.timestamps
      t.index [:resource_id, :booking_id], unique: true
    end
  end
end
