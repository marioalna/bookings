class AddBlockedToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :blocked, :boolean, default: false, null: false
  end
end
