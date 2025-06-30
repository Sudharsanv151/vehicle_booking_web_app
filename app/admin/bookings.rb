ActiveAdmin.register Booking do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :user_id, :vehicle_id, :start_location, :end_location, :price, :booking_date, :status, :start_time, :end_time, :ride_status, :proposed_price, :customer_accepted
  
  filter :user_id, as: :select, collection: -> { User.all.map { |u| [u.name, u.id] } }
  filter :vehicle_id, as: :select, collection: -> { Vehicle.all.map { |v| [v.vehicle_type, v.id] } }
  filter :start_location
  filter :end_location
  filter :price
  filter :booking_date
  filter :status
  filter :ride_status
  filter :created_at
  
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :vehicle_id, :start_location, :end_location, :price, :booking_date, :status, :start_time, :end_time, :ride_status, :proposed_price, :customer_accepted]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
