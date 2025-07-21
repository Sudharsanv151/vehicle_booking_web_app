class Api::V1::VehiclesController < Api::BaseController

  before_action :doorkeeper_authorize!, except: [:index, :show, :rating, :available]
  before_action :reject_client_token, only: [:create, :update, :destroy]
  before_action :set_driver, only: [:create, :update, :destroy]
  before_action :set_vehicle, only: [:show, :update, :destroy, :rating, :current_customer]

  def index
    request.format = :json 
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

  end

  def show
  end

  def create
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

 
  def available
    @vehicles = Vehicle.available.order(created_at: :desc)
    render "api/v1/vehicles/index"
  end

  def rating
    average = @vehicle.average_rating
    ratings = @vehicle.ratings.select(:id, :stars, :comments, :user_id, :created_at)

    render json: { average_rating: average, ratings: ratings }
  end

  def current_customer
    unless owns_vehicle?(params[:id]) || client_credentials_token?
      return render json: { error: "Only the vehicle's driver or a client can access this" }, status: :forbidden
    end

    customer = @vehicle.current_customer

    if customer
      render json: customer.as_json(only: [:id, :name, :email, :mobile_no])
    else
      render json: { message: "Vehicle is not currently assigned to any active booking" }
    end
  end

  private

  def reject_client_token
    if client_credentials_token?
      render json: { error: "Only users(drivers) can perform this action" }, status: :forbidden
    end
  end

  def owns_vehicle?(vehicle_id)
    current_user&.userable_type == "Driver" &&
      current_user.userable.vehicles.exists?(id: vehicle_id)
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
      render json: { error: "Vehicle not found or not owned by you" }, status: :not_found unless @vehicle
    else
      @vehicle = Vehicle.find_by(id: params[:id])
      render json: { error: "Vehicle not found" }, status: :not_found unless @vehicle
    end
  end

  def vehicle_params
    params.require(:vehicle).permit(:vehicle_type, :model, :licence_plate, :capacity)
  end

end
