class VehiclesController < ApplicationController

  before_action :set_vehicle, only: [:edit, :update, :destroy, :ratings, :ride_history]
  before_action :set_driver, only: [:create, :driver_index]

  def index
    @vehicles = Vehicle.includes(:tags, :driver)
  end

  def new
    @vehicle = Vehicle.new
  end


  def create
    @vehicle = Vehicle.new(vehicle_params)
    @vehicle.driver_id = User.find_by(id: session[:user_id])&.userable&.id

    if @vehicle.save
      flash[:notice]="Vehicle added successfully!"
      redirect_to driver_vehicles_path
    else
      flash[:alert]="Failed to add vehicle"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      flash[:notice]="Updated the vehicle details successfully!"
      redirect_to driver_vehicles_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @vehicle.bookings.not_finished.exists?
      redirect_to driver_vehicles_path, alert: "Cannot delete vehicle with active or pending bookings"
    else
      @vehicle.bookings.finished.destroy_all
      @vehicle.destroy
      redirect_to driver_vehicles_path, notice: "Vehicle and completed bookings deleted"
    end
  end

  def driver_index
    @vehicles = @driver.vehicles
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

  def set_driver
    @driver = User.find_by(id: session[:user_id])&.userable
  end

  def vehicle_params
    params.require(:vehicle).permit(:model, :vehicle_type, :capacity, :licence_plate, :image, tag_ids:[])
  end
end