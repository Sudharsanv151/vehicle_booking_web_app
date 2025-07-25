# frozen_string_literal: true

class Vehicle < ApplicationRecord
  include VehicleValidation

  acts_as_paranoid

  belongs_to :driver
  has_many :bookings, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy
  has_and_belongs_to_many :tags
  has_one_attached :image

  validates :vehicle_type, presence: true

  scope :by_type, ->(type) { where(vehicle_type: type) }
  scope :with_tag, ->(tag_id) { joins(:tags).where(tags: { id: tag_id }) }
  scope :available, lambda {
    left_outer_joins(:bookings).where(bookings: { status: [nil, false] }).or(Vehicle.left_outer_joins(:bookings).where(bookings: { id: nil })).distinct
  }
  scope :with_ratings_above, ->(stars) { joins(:ratings).group(:id).having('AVG(ratings.stars) >= ?', stars) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id model vehicle_type driver_id licence_plate created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[driver bookings]
  end

  def average_rating
    ratings.average(:stars)&.round(1) || 'not rated yet'
  end

  def booked?
    bookings.approved.not_finished.exists?
  end

  def current_customer
    bookings.approved.not_finished.last&.user
  end
end
