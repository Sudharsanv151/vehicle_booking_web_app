# frozen_string_literal: true

attributes :id, :start_location, :end_location, :price, :booking_date,
           :start_time, :end_time, :status, :ride_status

node(:customer_id, &:user_id)
node(:vehicle_id, &:vehicle_id)

child :vehicle do
  attributes :id, :vehicle_type, :model, :licence_plate
end
