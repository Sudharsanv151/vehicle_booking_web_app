# frozen_string_literal: true

module BookingView
  extend ActiveSupport::Concern

  included do
  end

  def customer_history
    @user = current_user
    @completed = current_user.bookings.where(ride_status: true).order(start_time: :desc).page(params[:page]).per(8)
  end

  def driver_history
    @bookings = Booking.joins(:vehicle).where(vehicles: { driver_id: @driver_id },
                                              ride_status: true).page(params[:page]).per(8)
  end

  def driver_ongoing
    @ongoing_bookings = Booking.joins(:vehicle).where(vehicles: { driver_id: @driver_id }, status: true, ride_status: false).includes(
      :user, :vehicle, :payment
    )
  end

  def requests
    @requests = Booking.joins(:vehicle).where(vehicles: { driver_id: @driver_id }, status: false).includes(:user,
                                                                                                           :vehicle)
  end
end
