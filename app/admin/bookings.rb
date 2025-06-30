ActiveAdmin.register Booking do

  permit_params :user_id, :vehicle_id, :start_location, :end_location, :price, :booking_date, :status, :start_time, :end_time, :ride_status, :proposed_price, :customer_accepted
  
  filter :user_id, as: :select, collection: -> { User.all.map { |u| [u.name, u.id] } }
  filter :vehicle_id, as: :select, collection: -> { Vehicle.all.map { |v| [v.vehicle_type, v.id] } }
  filter :start_location
  filter :end_location
  filter :price
  filter :booking_date
  filter :status, as: :select
  filter :ride_status, as: :select
  filter :start_time
  filter :end_time
  filter :created_at
  
  index do
    selectable_column
    id_column
    column :user
    column :vehicle
    column :start_location
    column :end_location
    column :start_time
    column :price
    column :status
    column :ride_status
    actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :vehicle
      row :start_location
      row :end_location
      row :price
      row :proposed_price
      row :customer_accepted
      row :booking_date
      row :start_time
      row :end_time
      row :status
      row :ride_status
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Booking Details" do
      f.input :user, as: :select, collection: User.all.map { |u| [u.name, u.id] }
      f.input :vehicle, as: :select, collection: Vehicle.all.map { |v| [v.model, v.id] }
      f.input :start_location
      f.input :end_location
      f.input :price
      f.input :booking_date, as: :datepicker
      f.input :start_time, as: :datetime_picker
      f.input :end_time, as: :datetime_picker
      f.input :status
      f.input :ride_status
      f.input :customer_accepted
    end
    f.actions
  end
  
end
