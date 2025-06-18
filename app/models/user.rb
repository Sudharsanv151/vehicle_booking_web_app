class User < ApplicationRecord
  belongs_to :userable, polymorphic: true
  has_many :bookings
  has_many :ratings
  has_many :rewards
end
