class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  has_one :payment
  has_many :ratings, as: :rateable

  def driver
    vehicle.driver
  end
end
