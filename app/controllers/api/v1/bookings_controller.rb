module Api
  module V1
    class BookingsController < Api::BaseController

      before action :set_booking

      def index
        @bookings=Booking.all
        render json:@bookings
      end

      def show
        render json:@booking
      end

      def create
        @booking=Booking.new(booking_params)

        if @booking.save
          render json:@booking, status: :created
        else
          render json:{errors:@booking.errors}, status: :unprocessable_entity
        end
      end

      def destroy
        @booking.destroy
        render json: {message:"Booking deleted successfully"}
      end

      def update
        if @booking.update(booking_params)
          render json:@booking
        else
          render json: {errors:@booking.errors}, status: :unprocessable_entity
        end 
      end

      private

      def set_booking
        @booking=Booking.find_by(id:params[:id])
      rescue ActionRecord::RecordNotFound
        render json:{message:"booking not found"}, status: :not_found
      end

    end
  end
end
