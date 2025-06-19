class Vehicle < ApplicationRecord
  belongs_to :driver
  has_many :bookings
  has_many :ratings, as: :rateable
  has_and_belongs_to_many :tags

  validates :model, :vehicle_type, :licence_plate, :capacity, presence:true
  validates :capacity, numericality:{only_integer:true, greater_than:0}

end
