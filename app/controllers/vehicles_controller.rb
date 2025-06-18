class VehiclesController < ApplicationController
  def new
    @vehicle = Vehicle.new
  end

  def create
    driver = User.find(session[:user_id]).userable
    @vehicle = driver.vehicles.new(vehicle_params)
    if @vehicle.save
      redirect_to home_path
    else
      render :new
    end
  end

  def destroy
    @vehicle = Vehicle.find(params[:id])
    if @vehicle.bookings.exists?
      redirect_to home_path, alert: "Cannot delete vehicle with existing bookings"
    elsif @vehicle.driver_id == User.find(session[:user_id]).userable.id
      @vehicle.destroy
      redirect_to home_path, notice: "Vehicle deleted"
    else
      redirect_to home_path, alert: "Not authorized"
    end
  end


  def edit
    @vehicle = Vehicle.find(params[:id])
  end

  def update
    @vehicle = Vehicle.find(params[:id])
    if @vehicle.update(vehicle_params)
      redirect_to home_path
    else
      render :edit
    end
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:vehicle_type, :model, :licence_plate, :capacity, tag_ids: [])
  end
end
