# frozen_string_literal: true

class VehiclesController < ApplicationController
  include VehicleFilter
  include DriverVehicleAction

  before_action :set_vehicle, only: %i[edit update destroy ratings ride_history]

  def index
    @tags = Tag.all
    @types = Vehicle.distinct.pluck(:vehicle_type)

    @vehicles = apply_vehicle_filters(Vehicle.includes(:tags, :driver))
    @vehicles = @vehicles.page(params[:page]).per(8)
  end

  def new
    @vehicle = Vehicle.new
  end

  def edit; end

  def update
    if @vehicle.update(vehicle_params)
      flash[:notice] = 'Updated the vehicle details successfully!'
      redirect_to driver_vehicles_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @vehicle.bookings.not_finished.exists?
      redirect_to driver_vehicles_path, alert: 'Cannot delete vehicle with active or pending bookings'
    else
      @vehicle.bookings.finished.destroy_all
      @vehicle.destroy
      redirect_to driver_vehicles_path, notice: 'Vehicle and completed bookings deleted'
    end
  end

  def ratings
    @ratings = @vehicle.ratings.includes(:user)
  end

  def ride_history
    @bookings = @vehicle.bookings.where(ride_status: true)
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find_by(id: params[:vehicle_id] || params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:model, :vehicle_type, :capacity, :licence_plate, :image, tag_ids: [])
  end
end
