class VehiclesController < ApplicationController
  
  before_action :set_vehicle, only: [:edit, :update, :destroy, :ratings, :ride_history]
  before_action :set_driver, only: [:create, :driver_index]

  def index
    @tags = Tag.all
    @types = Vehicle.distinct.pluck(:vehicle_type)
    @vehicles = Vehicle.includes(:tags, :driver)

    if params[:query].present?
      keyword = params[:query].downcase
      @vehicles = @vehicles.select do |v|
        v.model.downcase.include?(keyword) || v.driver.user.name.downcase.include?(keyword)
      end
    else
      @vehicles = @vehicles.by_type(params[:vehicle_type]) if params[:vehicle_type].present? && params[:vehicle_type] != "All"
      @vehicles = @vehicles.with_tag(params[:tag_id]) if params[:tag_id].present?
      @vehicles = @vehicles.with_ratings_above(params[:min_rating].to_f) if params[:min_rating].present?
    end
  end


  def new
    @vehicle = Vehicle.new
  end

  def create
    service = VehicleCreationService.new(vehicle_params, @driver.id, params[:new_tags])
    @vehicle = service.call

    if @vehicle.persisted?
      flash[:notice] = "Vehicle added successfully!"
      redirect_to driver_vehicles_path
    else
      flash[:alert] = "Failed to add vehicle"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      flash[:notice] = "Updated the vehicle details successfully!"
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
    @driver = current_user&.userable
  end

  def vehicle_params
    params.require(:vehicle).permit(:model, :vehicle_type, :capacity, :licence_plate, :image, tag_ids: [])
  end
end
