ActiveAdmin.register Booking do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :user_id, :vehicle_id, :start_location, :end_location, :price, :booking_date, :status, :start_time, :end_time, :ride_status, :proposed_price, :customer_accepted
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :vehicle_id, :start_location, :end_location, :price, :booking_date, :status, :start_time, :end_time, :ride_status, :proposed_price, :customer_accepted]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
