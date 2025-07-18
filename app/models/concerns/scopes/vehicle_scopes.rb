module Scopes
  module VehicleScopes
    extend ActiveSupport::Concern

    included do
      scope :by_type, ->(type) { where(vehicle_type: type) }
      scope :with_tag, ->(tag_id) { joins(:tags).where(tags: { id: tag_id }) }
      scope :available, -> {
        left_outer_joins(:bookings)
          .where(bookings: { status: [nil, false] })
          .or(Vehicle.left_outer_joins(:bookings).where(bookings: { id: nil }))
          .distinct
      }
      scope :with_ratings_above, ->(stars) {
        joins(:ratings).group(:id).having('AVG(ratings.stars) >= ?', stars)
      }
    end
  end
end
