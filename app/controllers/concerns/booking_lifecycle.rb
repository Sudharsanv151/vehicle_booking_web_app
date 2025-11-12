# frozen_string_literal: true

module BookingLifecycle
  extend ActiveSupport::Concern

  included do
  end

  def destroy
    if Time.current < @booking.start_time.in_time_zone - 30.minutes
      @booking.update(cancelled_by: current_user.userable_type.downcase, cancelled_at: Time.current)
      flash[:notice] = 'Booking cancelled!'
    else
      flash[:alert] = 'Cannot cancel booking within 30 minutes of start time.'
    end

    redirect_back fallback_location: bookings_path
  end

  def accept
    if BookingStatusService.accept(@booking.id)
      flash[:notice] = 'Booking accepted!'
    else
      flash[:alert] = 'This driver already has an accepted booking around this time.'
    end
    redirect_to driver_ongoing_path
  end

  def reject
    role = current_user.userable_type.downcase
    service = BookingStatusService.new(@booking)
    service.reject(role)
    flash[:notice] = 'Booking rejected!'
    redirect_to booking_requests_path
  end

  def finish
    service = BookingStatusService.finish(@booking)
    if service.finish
      flash[:notice] = 'Ride completed!'
    else
      flash[:alert] = 'Failed to complete ride.'
    end
    redirect_to driver_ongoing_path
  end
end
