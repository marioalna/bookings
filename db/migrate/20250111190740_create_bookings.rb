class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user
      t.references :schedule_category
      t.date :start_on, null: false
      t.date :end_on
      t.integer :participants, default: 0, null: false
      t.timestamps
    end

    add_index :bookings, %i[user_id schedule_category_id start_on], unique: true
  end
end
