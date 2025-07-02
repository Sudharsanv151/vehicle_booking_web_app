module Api
  module V1 
    class VehiclesController < Api::BaseController

      before_action :set_vehicle

      def index
        @vehicles=Vehicle.all
        render json: @vehicles
      end

      def show
        render json: @vehicle
      end

      def create
        @vehicle=Vehicle.new(vehicle_params)

        if @vehicle.save
          render json: @vehicle, status: :created
        else
          render json: {errors: @vehicle.errors} ,status: :unprocessable_entity
        end
      end

      def destroy
        @vehicle.destroy
        render json: {message:"Vehicle deleted successfully!"}
      end

      def update
        if @vehicle.update(vehicle_params)
          render json: @vehicle
        else
          render json: @vehicle.errors, status: :unprocessable_entity
        end  
      end

      private
    
      def vehicle_params
        params.require(:vehicle).permit(:driver_id, :vehicle_type, :model, :licence_plate, :capacity)
      end

      def set_vehicle
        @vehicle=Vehicle.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {error:'Vehicle not found'}, status: :not_found
      end
      
    end
  end
end