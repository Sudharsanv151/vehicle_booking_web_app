# frozen_string_literal: true

class AddCancelledByAndCancelledAtToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :cancelled_by, :string
    add_column :bookings, :cancelled_at, :datetime
  end
end
