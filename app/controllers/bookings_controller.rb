class BookingsController < ApplicationController
  
  before_action :set_driver_id, only: [:driver_ongoing, :driver_history, :requests, :propose_price]

  def index
    user = current_user
    @requested = user.bookings.where(status: false)
    @ongoing = user.bookings.where(status: true, ride_status: false)
  end

  def new
    @vehicle = Vehicle.find_by(id: params[:vehicle_id])
    @user=current_user
    @booking = Booking.new
  end

  def create
    @booking = BookingCreateService.new(booking_params, current_user).call
    if @booking.persisted?
      flash[:notice] = "Booking requested successfully!"
      redirect_to bookings_path
    else
      @vehicle = Vehicle.find(@booking.vehicle_id)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    booking = Booking.find_by(id: params[:id])  
    if booking.user_id == current_user.id && !booking.status
      booking.destroy
      flash[:notice] = "Booking cancelled!"
    else
      flash[:alert] = "Cannot cancel booking"
    end
    redirect_to bookings_path
  end

  def propose_price
    booking = Booking.find_by(id: params[:id])
    if booking.customer_accepted
      flash[:alert] = "Customer has already accepted the final price"
    elsif BookingNegotiationService.propose_price(booking, @driver_id, params[:proposed_price])
      flash[:notice] = "Proposed new price to customer"
    else
      flash[:alert] = "Failed to propose price"
    end
    redirect_to booking_requests_path
  end


  def accept_price
    booking = Booking.find_by(id: params[:id])
    if BookingNegotiationService.accept_price(booking, session[:user_id])
      flash[:notice] = "New price accepted!"
    else
      flash[:alert] = "Failed to accept new price"
    end
    redirect_to bookings_path
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
    @user = current_user
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
    @driver_id = current_user&.userable&.id
  end
end
