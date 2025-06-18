class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.string :start_location
      t.string :end_location
      t.float :price
      t.datetime :booking_date
      t.boolean :status
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :ride_status

      t.timestamps
    end
  end
end
