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
  validate :booking_vehicle_exists
  validate :user_has_no_conflict, on: :create

  
  scope :pending, -> { where(status: false) }
  scope :approved, -> { where(status: true) }
  scope :finished, -> { where(ride_status: true) }
  scope :not_finished, -> { where(ride_status: false) }
  scope :upcoming, -> {where("start_time > ?",Time.current)}
  scope :past, -> {where("start_time < ?",Time.current)}
  scope :negotiated, ->{where.not(proposed_price:nil)}
  
  
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
    elsif start_time < Time.current
      errors.add(:start_time, "can't be in the past")
    end
  end

  def booking_vehicle_exists
    errors.add(:vehicle, "must be valid vehicle") unless Vehicle.exists?(vehicle_id)
  end

  def user_has_no_conflict
    return if user.nil?
    if user.bookings.where("start_time = ?",start_time).exists?
      errors.add(:base, "You already have a booking on same time")
    end 
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
