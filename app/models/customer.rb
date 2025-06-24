class Customer < ApplicationRecord
  has_one :user, as: :userable, dependent: :destroy
  has_many :bookings, through: :user
  has_many :payments, through: :bookings
  has_many :rewards, through: :user

  validates :location, presence:true, length:{minimum:3}
  
  scope :with_bookings,->{joins(:bookings).distinct}
  scope :recent,->{order(created_at:desc)}
  
  before_validation :format_location

  def total_reward_points
    rewards.sum(:points)
  end

  def total_completed_rides
    bookings.where(ride_status:true)
  end

  def name
    user&.name || "undefined"
  end

  private

  def format_location
    self.location=location.to_s.strip.capitalize
  end

end
