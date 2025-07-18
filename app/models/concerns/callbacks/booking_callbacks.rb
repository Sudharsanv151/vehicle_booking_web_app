# app/models/concerns/callbacks/booking_callbacks.rb
module Callbacks
  module BookingCallbacks
    extend ActiveSupport::Concern

    included do
      before_validation :normalize_locations
      after_update :reward_customer_after_completion
      after_destroy :delete_unwanted_ratings
    end

    private

    def normalize_locations
      self.start_location = start_location.strip.downcase if start_location.present?
      self.end_location   = end_location.strip.downcase if end_location.present?
    end

    def reward_customer_after_completion
      return unless saved_change_to_ride_status? && ride_status?

      Reward.create(
        user_id: user_id,
        points: 10,
        reward_type: "Completed Ride"
      )
    end

    def delete_unwanted_ratings
      ratings.destroy_all
    end
  end
end
