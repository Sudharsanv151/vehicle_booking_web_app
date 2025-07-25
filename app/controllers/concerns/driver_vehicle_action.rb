# frozen_string_literal: true

module DriverVehicleAction
  extend ActiveSupport::Concern

  included do
    before_action :set_driver, only: %i[create driver_index]
  end

  def create
    service = VehicleCreationService.new(vehicle_params, @driver.id, params[:new_tags])
    @vehicle = service.call

    if @vehicle.persisted?
      flash[:notice] = 'Vehicle added successfully!'
      redirect_to driver_vehicles_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def driver_index
    @types = Vehicle.distinct.pluck(:vehicle_type).compact
    @tags = Tag.all

    base_vehicles = Vehicle.where(driver_id: current_user.userable.id)
    @vehicles = apply_vehicle_filters(base_vehicles)

    @vehicles = @vehicles.page(params[:page]).per(8)
  end

  private

  def set_driver
    @driver = current_user&.userable
  end
end
