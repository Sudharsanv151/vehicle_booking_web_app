class AddDeletedAtToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :deleted_at, :datetime
    add_index :bookings, :deleted_at
  end
end
