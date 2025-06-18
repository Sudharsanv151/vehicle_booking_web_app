class Driver < ApplicationRecord
  has_one :user, as: :userable
  has_many :vehicles
  has_many :bookings, through: :vehicles
end
