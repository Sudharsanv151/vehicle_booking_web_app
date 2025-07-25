# frozen_string_literal: true

#
class BookingsController < ApplicationController
  include BookingLifecycle
  include BookingView

  before_action :set_driver_id, only: %i[driver_ongoing driver_history requests propose_price]
  before_action :set_booking, only: %i[propose_price accept_price accept reject finish destroy]

  def index
    @requested = current_user.bookings.where(status: [nil, false]).where('start_time > ?', Time.current)
    @ongoing = current_user.bookings.where(status: true, end_time: nil, ride_status: false).order(start_time: :asc)
  end

  def new
    @vehicle = Vehicle.find_by(id: params[:vehicle_id])
    @user = current_user
    @booking = Booking.new
  end

  def create
    @booking = BookingCreateService.new(booking_params, current_user).call
    if @booking.persisted?
      flash[:notice] = 'Booking requested successfully!'
      redirect_to bookings_path
    else
      @vehicle = Vehicle.find(@booking.vehicle_id)
      render :new, status: :unprocessable_entity
    end
  end

  def propose_price
    if @booking.customer_accepted
      flash[:alert] = 'Customer has already accepted the final price'
    elsif BookingNegotiationService.propose_price(@booking, @driver_id, params[:proposed_price])
      flash[:notice] = 'Proposed new price to customer'
    else
      flash[:alert] = 'Failed to propose price'
    end
    redirect_to booking_requests_path
  end

  def accept_price
    if BookingNegotiationService.accept_price(@booking, current_user.id)
      flash[:notice] = 'New price accepted!'
    else
      flash[:alert] = 'Failed to accept new price'
    end
    redirect_to bookings_path
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
    return if @booking

    flash[:alert] = 'Booking not found'
    redirect_back fallback_location: bookings_path
  end
end
