class SetDefaultStatusForBookings < ActiveRecord::Migration[7.1]
  def change
    change_column_default :bookings, :status, false
    change_column_default :bookings, :ride_status, false

    # Also fix existing rows where status/ride_status is nil
    reversible do |dir|
      dir.up do
        Booking.where(status: nil).update_all(status: false)
        Booking.where(ride_status: nil).update_all(ride_status: false)
      end
    end
  end
end
