module Validations::BookingValidations
  extend ActiveSupport::Concern

  included do
    validates :start_location, :end_location, :start_time, presence: true
    validate :price_must_be_valid
    validate :start_time_not_past
    validate :end_time_must_be_after_start_time
    validate :user_has_no_conflict, on: :create
    validate :no_conflicting_driver_bookings, on: :create
    validate :start_and_end_locations_cannot_be_same
  end

  private

  def price_must_be_valid
    if price.blank?
      errors.add(:price, "can't be blank")
    elsif price.to_f <= 50
      errors.add(:price, "must be greater than 50")
    end
  end

  def start_time_not_past
    if start_time.blank?
      errors.add(:start_time, "can't be blank")
    elsif start_time < 15.minutes.from_now
      errors.add(:start_time, "must be at least 15 minutes from now")
    end
  end

  def end_time_must_be_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end

  def user_has_no_conflict
    return if user.nil?

    if Booking.where(user_id: user.id, status: true, cancelled_by: nil)
              .where('ABS(EXTRACT(EPOCH FROM (start_time - ?)) / 3600.0) < 1', start_time)
              .exists?
      errors.add(:base, "You already have a booking within 1 hour of this time")
    end
  end

  def no_conflicting_driver_bookings
    return unless vehicle&.driver_id && start_time

    conflicts = Booking.joins(:vehicle)
                       .where(vehicles: { driver_id: vehicle.driver_id })
                       .where(status: true, cancelled_by: nil)
                       .where('ABS(EXTRACT(EPOCH FROM (start_time - ?)) / 3600.0) < 1', start_time)

    errors.add(:base, 'Driver has another booking within 1 hour.') if conflicts.exists?
  end

  def start_and_end_locations_cannot_be_same
    if start_location.present? && end_location.present? && start_location == end_location
      errors.add(:end_location, "can't be the same as start location")
    end
  end
end
