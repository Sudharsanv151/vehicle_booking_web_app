# frozen_string_literal: true

module BookingValidation
  extend ActiveSupport::Concern

  included do
    validate :validate_locations_presence
    validate :validate_start_time_field
    validate :validate_price_field
    validate :end_time_must_be_after_start_time
    validate :user_has_no_conflict, on: :create
    validate :no_conflicting_driver_bookings, on: :create
    validate :start_and_end_locations_cannot_be_same

    before_validation :normalize_locations
    after_update :reward_customer_after_completion
    after_destroy :delete_unwanted_ratings
  end

  def driver
    vehicle.driver
  end

  def final_price
    customer_accepted ? proposed_price : price
  end

  private

  def validate_locations_presence
    errors.add(:start_location, "can't be blank") if start_location.blank?
    return unless end_location.blank?

    errors.add(:end_location, "can't be blank")
  end

  def validate_price_field
    if price.blank?
      errors.add(:price, "can't be blank")
    elsif price.to_f <= 50
      errors.add(:price, 'must be greater than 50')
    end
  end

  def validate_start_time_field
    if start_time.blank?
      errors.add(:start_time, "can't be blank")
    elsif start_time < 15.minutes.from_now
      errors.add(:start_time, 'must be at least 15 minutes from now')
    end
  end

  def end_time_must_be_after_start_time
    return if start_time.blank? || end_time.blank?

    return unless end_time <= start_time

    errors.add(:end_time, 'must be after the start time')
  end

  def user_has_no_conflict
    return if user.nil? || start_time.blank?

    if Booking.where(user_id: user.id, status: true, cancelled_by: nil)
              .where('ABS(EXTRACT(EPOCH FROM (start_time - ?)) / 3600.0) < 1', start_time)
              .exists?
      errors.add(:base, 'You already have a booking within 1 hour of this time')
    end
  end

  def no_conflicting_driver_bookings
    return unless vehicle&.driver_id && start_time.present?

    conflicts = Booking.joins(:vehicle)
                       .where(vehicles: { driver_id: vehicle.driver_id })
                       .where(status: true, cancelled_by: nil)
                       .where('ABS(EXTRACT(EPOCH FROM (start_time - ?)) / 3600.0) < 1', start_time)

    return unless conflicts.exists?

    errors.add(:base, 'Driver has another booking within 1 hour.')
  end

  def start_and_end_locations_cannot_be_same
    return unless start_location.present? && end_location.present? && start_location == end_location

    errors.add(:end_location, "can't be the same as start location")
  end

  def normalize_locations
    self.start_location = start_location.strip.downcase if start_location.present?
    self.end_location   = end_location.strip.downcase if end_location.present?
  end

  def reward_customer_after_completion
    return unless saved_change_to_ride_status? && ride_status?

    Reward.create(
      user_id: user_id,
      points: 10,
      reward_type: 'Completed Ride'
    )
  end

  def delete_unwanted_ratings
    ratings.destroy_all
  end
end
