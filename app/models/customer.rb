class Customer < ApplicationRecord
  has_one :user, as: :userable
  has_many :bookings, through: :user
end
