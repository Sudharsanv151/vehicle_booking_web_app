module Api
  module V1
    class BookingsController < Api::BaseController
      
      before_action :set_userable
      before_action :set_booking, only:[:show,:update]

      def index
        if customer?
          @bookings=@userable.bookings.order(created_at: :desc)
        elsif driver?
          vehicle_ids=@userable.vehicles.pluck(:id)
          @bookings=Booking.where(vehicle_id: vehicle_ids).order(created_at: :desc)
        end
        render "api/v1/bookings/index"
      end
    

      def show
        render "api/v1/bookings/show"
      end


      def create
        unless customer?
          return render json: {error:"You are not authorized to perform this action"}, status: :forbidden
        end

        @booking=@userable.bookings.new(booking_params)

        if @booking.save
          render "api/v1/bookings/show", status: :created
        else 
          render json:@booking.errors, status: :unprocessable_entity
        end
      end

      # def destroy
      #   @booking.destroy
      #   render json: {message:"Booking deleted successfully"}
      # end

      def update
        unless driver?
          return render json: {error:"You are not authorized to perform this action"}, status: :forbidden
        end

        if @booking.update(driver_booking_params)
          render "api/v1/bookings/show"
        else
          render json: {errors:@booking.errors}, status: :unprocessable_entity
        end 
      end


      private

      def set_userable
        @userable=current_user&.userable
      end

      def set_booking
        @booking=Booking.find_by(id: params[:id])
        unless @booking
          return render json: {error: "Booking not found!"}, status: :not_found
        end

        if customer? && @booking.user_id!=current_user.id
          render json: {error:"You are not authorized to perform this action"}, status: :forbidden
        elsif driver?
          vehicle_ids = current_user.userable.vehicles.pluck(:id)
          unless vehicle_ids.include?(@booking.vehicle_id)
            render json: {error:"You are not authorized to perform this action"}, status: :forbidden
          end
        end
      end

      def booking_params
        params.require(:booking).permit(:user_id, :vehicle_id, :start_location, :end_location, :price, :booking_date, :start_time)
      end

      def driver_booking_params
        params.require(:booking).permit(:status, :start_time, :end_time, :ride_status)
      end

      def customer?
        current_user&.userable_type=="Customer"
      end

      def driver?
        current_user&.userable_type=="Driver"
      end



    end
  end
end
