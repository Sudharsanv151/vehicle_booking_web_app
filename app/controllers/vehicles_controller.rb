class VehiclesController < ApplicationController
  def index
    @vehicles = Vehicle.includes(:tags, :driver)
  end

  def new
    @vehicle = Vehicle.new
  end

  # def show
  #   redirect_to   
  # end

  def create
    @vehicle = Vehicle.new(vehicle_params)
    @vehicle.driver_id = User.find(session[:user_id]).userable.id
    if @vehicle.save
      flash[:notice]="Vehicle added successfully!"
      redirect_to driver_vehicles_path
    else
      flash[:alert]="Failed to add vehicle"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vehicle = Vehicle.find(params[:id])
  end

  def update
    @vehicle = Vehicle.find(params[:id])
    if @vehicle.update(vehicle_params)
      flash[:notice]="Updated the vehicle details successfully!"
      redirect_to driver_vehicles_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    vehicle = Vehicle.find(params[:id])

    if vehicle.bookings.not_finished.exists?
      redirect_to driver_vehicles_path, alert: "Cannot delete vehicle with active or pending bookings"
    else
      vehicle.bookings.finished.destroy_all
      vehicle.destroy
      redirect_to driver_vehicles_path, notice: "Vehicle and completed bookings deleted"
    end
  end



  def driver_index
    @vehicles = User.find(session[:user_id]).userable.vehicles
  end

  def ratings
    @vehicle = Vehicle.find(params[:vehicle_id])
    @ratings = @vehicle.ratings.includes(:user)
  end

  def ride_history
    @vehicle = Vehicle.find(params[:vehicle_id])
    @bookings = @vehicle.bookings.where(ride_status: true)
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:model, :vehicle_type, :capacity, :licence_plate, :image, tag_ids:[])
  end
end