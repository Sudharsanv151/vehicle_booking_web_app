object @vehicle

attributes :id, :vehicle_type, :model, :licence_plate, :capacity, :created_at, :updated_at

node(:driver_id) { |v| v.driver_id }

child :driver do
  attributes :id, :name, :licence_no
end
