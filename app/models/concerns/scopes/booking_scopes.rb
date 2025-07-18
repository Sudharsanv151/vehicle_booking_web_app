module Scopes::BookingScopes
  extend ActiveSupport::Concern

  included do
    scope :pending, -> { where(status: false) }
    scope :approved, -> { where(status: true) }
    scope :finished, -> { where(ride_status: true) }
    scope :not_finished, -> { where(ride_status: false) }
    scope :upcoming, -> { where("start_time > ?", Time.current) }
    scope :negotiated, -> { where.not(proposed_price: nil) }
    scope :active, -> { where(cancelled_at: nil) }
    scope :cancelled, -> { where.not(cancelled_at: nil) }
  end
end
