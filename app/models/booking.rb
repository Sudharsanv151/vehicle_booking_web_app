class Booking < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :user
  belongs_to :vehicle
  has_one :payment, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy
  has_one :driver, through: :vehicle


  validates :start_location, :end_location, :start_time, presence: true
  validate :price_must_be_valid
  validate :start_time_not_past
  validate :end_time_must_be_after_start_time
  validate :user_has_no_conflict, on: :create
  validate :no_conflicting_driver_bookings, on: :create
  validate :start_and_end_locations_cannot_be_same


  
  scope :pending, -> { where(status: false) }
  scope :approved, -> { where(status: true) }
  scope :finished, -> { where(ride_status: true) }
  scope :not_finished, -> { where(ride_status: false) }
  scope :upcoming, -> {where("start_time > ?",Time.current)}
  scope :negotiated, ->{where.not(proposed_price:nil)}
  scope :active, -> { where(cancelled_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }

  
  before_validation :normalize_locations
  after_update :reward_customer_after_completion
  after_destroy :delete_unwanted_ratings

  def self.ransackable_attributes(auth_object = nil)
    %w[booking_date created_at customer_accepted end_location end_time id price proposed_price ride_status start_location start_time status updated_at user_id vehicle_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user vehicle ratings payment]
  end


  def driver
    vehicle.driver
  end

  def final_price
    customer_accepted ? proposed_price : price
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

    if Booking.where(user_id: user.id, status: true)
              .where('ABS(EXTRACT(EPOCH FROM (start_time - ?)) / 3600.0) < 1', start_time)
              .exists?
      errors.add(:base, "You already have a booking within 1 hour of this time")
    end
  end

  
  def no_conflicting_driver_bookings
    return unless vehicle&.driver_id && start_time

    conflicts = Booking.joins(:vehicle)
                      .where(vehicles: { driver_id: vehicle.driver_id })
                      .where(status: true)
                      .where('ABS(EXTRACT(EPOCH FROM (start_time - ?)) / 3600.0) < 1', start_time)

    if conflicts.exists?
      errors.add(:base, 'Driver has another booking within 1 hour.')
    end
  end


  def start_and_end_locations_cannot_be_same
    if start_location.present? && end_location.present? && start_location == end_location
      errors.add(:end_location, "can't be the same as start location")
    end
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
      reward_type: "Completed Ride"
    )
  end

  def delete_unwanted_ratings
    ratings.destroy_all
  end

end
