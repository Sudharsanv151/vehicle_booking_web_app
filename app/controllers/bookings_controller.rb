class BookingsController < ApplicationController
  
  before_action :set_driver_id, only: [:driver_ongoing, :driver_history, :requests, :propose_price]
  before_action :set_booking, only: [:propose_price, :accept_price, :accept, :reject, :finish, :destroy]

  def index
    @requested = current_user.bookings.where(status: false)
    @ongoing = current_user.bookings.where(status: true, ride_status: false)
  end

  def new
    @vehicle = Vehicle.find_by(id: params[:vehicle_id])
    @user = current_user
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
    if @booking.user_id == current_user.id && !@booking.status
      @booking.destroy
      flash[:notice] = "Booking cancelled!"
    else
      flash[:alert] = "Cannot cancel booking"
    end
    redirect_to bookings_path
  end

  def propose_price
    if @booking.customer_accepted
      flash[:alert] = "Customer has already accepted the final price"
    elsif BookingNegotiationService.propose_price(@booking, @driver_id, params[:proposed_price])
      flash[:notice] = "Proposed new price to customer"
    else
      flash[:alert] = "Failed to propose price"
    end
    redirect_to booking_requests_path
  end

  def accept_price
    if BookingNegotiationService.accept_price(@booking, current_user.id)
      flash[:notice] = "New price accepted!"
    else
      flash[:alert] = "Failed to accept new price"
    end
    redirect_to bookings_path
  end

  def accept
    if BookingStatusService.accept(@booking.id)
      flash[:notice] = "Booking accepted!"
    else
    flash[:alert] = "This driver already has an accepted booking around this time."
    end
    redirect_to driver_ongoing_path
  end

  def reject
    BookingStatusService.reject(@booking.id)
    flash[:notice] = "Booking rejected!"
    redirect_to booking_requests_path
  end

  def finish
    BookingStatusService.finish(@booking.id)
    flash[:notice] = "Ride completed!"
    redirect_to driver_ride_history_path
  end

  def customer_history
    @user = current_user
    @completed = current_user.bookings.where(ride_status: true).order(start_time: :desc)
  end

  def driver_history
    @bookings = Booking.joins(:vehicle).where(vehicles: { driver_id: @driver_id }, ride_status: true)
  end

  def driver_ongoing
    @ongoing_bookings = Booking.joins(:vehicle).where(vehicles: { driver_id: @driver_id }, status: true, ride_status: false).includes(:user, :vehicle, :payment)
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

  def set_booking
    @booking = Booking.find_by(id: params[:id])
    unless @booking
      flash[:alert] = "Booking not found"
      redirect_back fallback_location: bookings_path
    end
  end
end
