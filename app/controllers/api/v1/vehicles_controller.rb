module Api
  module V1 
    class VehiclesController < Api::BaseController

      before_action :require_driver!
      before_action :set_driver
      before_action :set_vehicle, only:[:show, :destroy, :update]

      def index
        @vehicles=@driver.vehicles
        render "api/v1/vehicles/index"
      end

      def show
        render "api/v1/vehicles/show"
      end

      def create
        @vehicle=@driver.vehicles.new(vehicle_params)

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
      
      def set_driver
        @driver=current_user&.userable
      end

      def set_vehicle
        @vehicle=@driver.vehicles.find_by(id:params[:id])
        unless @vehicle
          render json:{error:"Vehicle not found for you or its not your vehicle"}, status: :not_found
        end
      end

      def vehicle_params
        params.require(:vehicle).permit(:vehicle_type, :model, :licence_plate, :capacity)
      end
      
    end
  end
end