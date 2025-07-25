# frozen_string_literal: true

class Customer < ApplicationRecord
  acts_as_paranoid

  has_one :user, as: :userable
  has_many :bookings, through: :user
  has_many :payments, through: :bookings
  has_many :rewards, through: :user

  validates :location, presence: true, length: { minimum: 3 }

  scope :with_bookings, -> { joins(:bookings).distinct }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :format_location

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name mobile_no location created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[bookings payments rewards user]
  end

  def total_reward_points
    rewards.sum(:points)
  end

  def name
    user&.name || 'undefined'
  end

  private

  def format_location
    self.location = location.to_s.strip.capitalize
  end
end
