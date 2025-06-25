class AddNegotiationFieldsToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :proposed_price, :float
    add_column :bookings, :customer_accepted, :boolean, default:false
  end
end
