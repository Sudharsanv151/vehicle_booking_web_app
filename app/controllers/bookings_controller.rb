class BookingsController < ApplicationController
  def index
    user = User.find(session[:user_id])
    @requested = user.bookings.where(status: false)
    @ongoing = user.bookings.where(status: true, ride_status: false)
  end

  def new
    @vehicle = Vehicle.find(params[:vehicle_id])
    @booking = Booking.new
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.user_id = session[:user_id]
    @booking.booking_date = Time.now

    if @booking.save
      flash[:notice]="Booking requested successfully!"
      redirect_to bookings_path
    else
      flash.now[:alert]="Booking failed!"
      @vehicle = Vehicle.find(@booking.vehicle_id)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    booking = Booking.find(params[:id])
    if booking.user_id == session[:user_id] && !booking.status
      booking.destroy
      flash[:notice]="Booking cancelled!"
      redirect_to bookings_path, notice: "Booking canceled"
    else
      flash[:alert]="Failed to cancel booking"
      redirect_to bookings_path, alert: "Cannot cancel"
    end
  end

  def accept
    booking = Booking.find(params[:id])
    booking.update(status: true)
    flash[:notice]="Booking accepted!"
    redirect_to driver_ongoing_path
  end


  def reject
    booking= Booking.find(params[:id])
    booking.destroy
    redirect_to booking_requests_path, notice:"Rejected the booking request"
  end



  def finish
    booking = Booking.find(params[:id])
    # flash[:notice]="Ride completed!"
    booking.update(ride_status: true, end_time: Time.current)
    redirect_to driver_ride_history_path
  end

  def customer_history
    @user = User.find(session[:user_id])
    @completed = @user.bookings.where(ride_status: true)
  end

  def driver_ongoing
    driver_id = User.find(session[:user_id]).userable.id
    @ongoing_bookings = Booking.joins(:vehicle).where(vehicles: { driver_id: driver_id }, status: true, ride_status: false).includes(:user, :vehicle, :payment)
  end
  
  def driver_history
    driver_id = User.find(session[:user_id]).userable.id
    @bookings = Booking.joins(:vehicle).where(vehicles: { driver_id: driver_id }, ride_status: true)
  end

  def requests
    driver_id = User.find(session[:user_id]).userable.id
    @requests = Booking.joins(:vehicle).where(vehicles: { driver_id: driver_id }, status: false).includes(:user, :vehicle)
  end

  private

  def booking_params
    params.require(:booking).permit(:vehicle_id, :start_location, :end_location, :start_time, :price)
  end
end