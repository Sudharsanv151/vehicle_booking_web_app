class Vehicle < ApplicationRecord
  belongs_to :driver
  has_many :bookings
  has_many :ratings, as: :rateable
  has_and_belongs_to_many :tags
  has_one_attached :image

  validates :image, :vehicle_type, presence:true
  validates :model, presence:true, length: {minimum:2}
  validates :licence_plate, presence:true, uniqueness:true
  validates :capacity, presence:true, numericality:{only_integer:true, greater_than:0}

end
