class Api::V1::VehiclesController < Api::BaseController

  before_action :doorkeeper_authorize!, except: [:index, :show]
  before_action :reject_client_token, only: [:create, :update, :destroy]
  before_action :set_driver, only: [:create, :update, :destroy]
  before_action :set_vehicle, only: [:show, :destroy, :update]

  def index
    if client_credentials_token? || doorkeeper_token.nil?
      @vehicles = Vehicle.all.order(created_at: :desc)
    elsif current_user.present?
      if driver?
        @vehicles = current_user.userable.vehicles
      elsif customer?
        @vehicles = Vehicle.all.order(created_at: :desc)
      end
    else
      return render json: { error: "Unauthorized request" }, status: :unauthorized
    end

    render "api/v1/vehicles/index"
  end

  def show
    render "api/v1/vehicles/show"
  end

  def create
    if doorkeeper_token.nil?
      return render json: { error: "Authentication token is required" }, status: :unauthorized
    end

    @vehicle = @driver.vehicles.new(vehicle_params)

    if @vehicle.save
      render "api/v1/vehicles/show", status: :created
    else
      render json: @vehicle.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy
    head :no_content
  end

  def update
    if @vehicle.update(vehicle_params)
      render "api/v1/vehicles/show"
    else
      render json: @vehicle.errors, status: :unprocessable_entity
    end  
  end

  

  private

  def reject_client_token
    if client_credentials_token?
      render json: { error: "Only users(drivers) can perform this action" }, status: :forbidden
    end
  end

  def set_driver
    if current_user&.userable_type == "Driver"
      @driver = current_user.userable
    else
      render json: { error: "Only drivers can perform this action" }, status: :forbidden
    end
  end

  def set_vehicle
    if driver?
      @vehicle = current_user.userable.vehicles.find_by(id: params[:id])
      unless @vehicle
        render json: { error: "Vehicle not found or not owned by you" }, status: :not_found
      end
    else
      @vehicle = Vehicle.find_by(id: params[:id])
      unless @vehicle
        render json: { error: "Vehicle not found" }, status: :not_found
      end
    end
  end

  def vehicle_params
    params.require(:vehicle).permit(:vehicle_type, :model, :licence_plate, :capacity)
  end

end
