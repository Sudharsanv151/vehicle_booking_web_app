module Callbacks
  module VehicleCallbacks
    extend ActiveSupport::Concern

    included do
      after_destroy :destroy_attaches_image
    end

    private

    def destroy_attaches_image
      image.purge_later if image.attached?
    end
  end
end
