# frozen_string_literal: true

class Booking < ApplicationRecord
  include BookingValidation

  acts_as_paranoid

  belongs_to :user
  belongs_to :vehicle
  has_one :payment, dependent: :destroy
  has_many :ratings, as: :rateable, dependent: :destroy
  has_one :driver, through: :vehicle

  scope :pending, -> { where(status: false) }
  scope :approved, -> { where(status: true) }
  scope :finished, -> { where(ride_status: true) }
  scope :not_finished, -> { where(ride_status: false) }
  scope :upcoming, -> { where('start_time > ?', Time.current) }
  scope :negotiated, -> { where.not(proposed_price: nil) }
  scope :active, -> { where(cancelled_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[booking_date created_at customer_accepted end_location end_time id price proposed_price ride_status
       start_location start_time status updated_at user_id vehicle_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user vehicle ratings payment]
  end
end
