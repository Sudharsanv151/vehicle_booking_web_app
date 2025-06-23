class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  has_one :payment, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy

  validates :start_location, :end_location, :price, presence: true
  validates :price, numericality: { greater_than: 50 }
  validates :start_time, presence: true
  validate :start_time_not_past

  
  scope :pending, -> { where(status: false) }
  scope :approved, -> { where(status: true) }
  scope :finished, -> { where(ride_status: true) }
  scope :not_finished, -> { where(ride_status: false) }
  
  after_update :reward_customer
  
  def start_time_not_past
    return if start_time.blank?
    if start_time < Time.current
      errors.add(:start_time, "cannot be in the past")
    end
  end

  def driver
    vehicle.driver
  end
  

  private

  def reward_customer
    if saved_change_to_ride_status? && ride_status == true
      Reward.create(
        user_id: user_id,
        points: 10,
        reward_type: "Completed Ride"
      )
    end
  end
end
