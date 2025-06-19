class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  has_one :payment, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy
  
  def driver
    vehicle.driver
  end

  validates :start_location, :end_location, :price, presence:true
  validates :price, numericality: {greater_than:50}

  scope :pending, ->{where(status:false)}
  scope :approved, ->{where(status:true)}
  scope :finished, ->{where(ride_status:true)}


end
