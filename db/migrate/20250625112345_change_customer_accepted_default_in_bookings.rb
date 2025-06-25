class ChangeCustomerAcceptedDefaultInBookings < ActiveRecord::Migration[7.1]
  def change
    change_column_default :bookings, :customer_accepted, from: nil, to: false
  end
end
