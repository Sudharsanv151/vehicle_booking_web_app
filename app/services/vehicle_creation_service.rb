# frozen_string_literal: true

class VehicleCreationService
  def initialize(vehicle_params, driver_id, new_tags)
    @vehicle_params = vehicle_params
    @driver_id = driver_id
    @new_tags = new_tags
  end

  def call
    vehicle = Vehicle.new(@vehicle_params)
    vehicle.driver_id = @driver_id
    attach_new_tags(vehicle) if @new_tags.present?
    vehicle.save
    vehicle
  end

  private

  def attach_new_tags(vehicle)
    tag_names = @new_tags.split(',').map(&:strip).reject(&:blank?)
    tags = tag_names.map { |name| Tag.find_or_create_by(name: name) }
    vehicle.tags += tags
  end
end
