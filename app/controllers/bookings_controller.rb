class BookingsController < ApplicationController

  before_action :set_driver_id, only: [:driver_ongoing, :driver_history, :requests]

  def index
    user = User.find_by(id:session[:user_id])
    @requested = user.bookings.where(status: false)
    @ongoing = user.bookings.where(status: true, ride_status: false)
  end

  def new
    @vehicle = Vehicle.find_by(id:params[:vehicle_id])
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
    booking = Booking.find_by(id:params[:id])
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
    BookingStatusService.accept(params[:id])
    flash[:notice] = "Booking accepted!"
    redirect_to driver_ongoing_path
  end

  def reject
    BookingStatusService.reject(params[:id])
    flash[:notice] = "Booking rejected!"
    redirect_to booking_requests_path
  end

  def finish
    BookingStatusService.finish(params[:id])
    flash[:notice] = "Ride completed!"
    redirect_to driver_ride_history_path
  end


  def customer_history
    @user = User.find_by(id:session[:user_id])
    @completed = @user.bookings.where(ride_status: true)
  end

  def driver_ongoing
    @ongoing_bookings = Booking.joins(:vehicle).where(vehicles: { driver_id: @driver_id }, status: true, ride_status: false).includes(:user, :vehicle, :payment)
  end
  
  def driver_history
    @bookings = Booking.joins(:vehicle).where(vehicles: { driver_id: @driver_id }, ride_status: true)
  end

  def requests
    @requests = Booking.joins(:vehicle).where(vehicles: { driver_id: @driver_id }, status: false).includes(:user, :vehicle)
  end

  private

  def booking_params
    params.require(:booking).permit(:vehicle_id, :start_location, :end_location, :start_time, :price)
  end

  def set_driver_id
    @driver_id = User.find_by(id: session[:user_id])&.userable&.id
  end

end