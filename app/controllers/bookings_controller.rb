class BookingsController < ApplicationController
  def new
    @vehicle = Vehicle.find_by(id: params[:vehicle_id])
    if @vehicle.nil?
      redirect_to home_path, alert: "Vehicle not found"
    else
      @booking = Booking.new
    end
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.user_id = session[:user_id]
    @booking.booking_date = Time.now
    @vehicle = Vehicle.find_by(id: @booking.vehicle_id)

    if @booking.save
      redirect_to home_path, notice: "Booking submitted successfully"
    else
      flash.now[:alert] = "Booking failed"
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    booking = Booking.find(params[:id])
    booking.update(status: true)
    redirect_to home_path, notice: "Booking accepted"
  end

  def destroy
    booking = Booking.find(params[:id])
    if booking.user_id == session[:user_id] && !booking.status
      booking.destroy
      redirect_to home_path, notice: "Booking canceled successfully"
    else
      redirect_to home_path, alert: "You can only cancel your pending bookings"
    end
  end


  def finish
    booking = Booking.find(params[:id])
    booking.update(ride_status: true)
    redirect_to home_path, notice: "Ride marked as finished"
  end

  private

  def booking_params
    params.require(:booking).permit(:vehicle_id, :start_location, :end_location, :price)
  end
end
