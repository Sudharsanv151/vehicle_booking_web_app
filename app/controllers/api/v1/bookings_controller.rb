class Api::V1::BookingsController < Api::BaseController

  before_action :doorkeeper_authorize!, except: [:index, :show]
  before_action :reject_client_token, only: [:create, :update, :ongoing, :pending, :customer_info ]
  before_action :set_userable
  before_action :set_booking, only: [:show, :update, :customer_info]

  def index
    if doorkeeper_token.nil?
      @bookings = Booking.none
      return render json: { error: "Authentication required" }, status: :unauthorized
    elsif client_credentials_token?
      @bookings = Booking.all.order(created_at: :desc)
    elsif current_user.present?
      if customer?
        @bookings = @userable.bookings.order(created_at: :desc)
      elsif driver?
        vehicle_ids = @userable.vehicles.pluck(:id)
        @bookings = Booking.where(vehicle_id: vehicle_ids).order(created_at: :desc)
      end
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    render "api/v1/bookings/index"
  end

  def show
    # if doorkeeper_token.nil?
    #   return render json: { error: "Authentication required" }, status: :unauthorized
    # end
    render "api/v1/bookings/show"
  end

  def create
    return forbidden unless customer?

    @booking = @userable.bookings.new(booking_params)
    @booking.user=current_user
    if @booking.save
      render "api/v1/bookings/show", status: :created
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    return forbidden unless driver?

    if @booking.update(driver_booking_params)
      render "api/v1/bookings/show"
    else
      render json: { errors: @booking.errors }, status: :unprocessable_entity
    end
  end

  def ongoing
    return render json: {error: "Unauthorized"}, status: :unauthorized if doorkeeper_token.nil?

    if customer?
      @bookings = @userable.bookings.where(status: true, ride_status: false)
    elsif driver?
      vehicle_ids = @userable.vehicles.pluck(:id)
      @bookings = Booking.where(vehicle_id: vehicle_ids, status: true, ride_status: false)
    end
    render "api/v1/bookings/index"
  end


  def pending
    return render json: { error: "Unauthorized" }, status: :unauthorized if doorkeeper_token.nil?

    if customer?
      @bookings = @userable.bookings.where(status: false, ride_status: false)
    elsif driver? 
      vehicle_ids = @userable.vehicles.pluck(:id)
      @bookings = Booking.where(vehicle_id: vehicle_ids, status: false)
    end
    render "api/v1/bookings/index"
  end


  def customer_info
    return forbidden unless driver?

    user = @booking.user
    render json: user.as_json(only: [:id, :email, :mobile_no])
  end


  private

  def reject_client_token
    if client_credentials_token?
      render json: { error: "Client credentials token cannot access this resource" }, status: :forbidden
    end
  end

  def set_userable
    if current_user
      @userable = current_user&.userable
    end
  end

  def set_booking
    @booking = Booking.find_by(id: params[:id])
    return render json: { error: "Booking not found" }, status: :not_found unless @booking

    if customer? && @booking.user_id != current_user.id
      return forbidden
    elsif driver?
      allowed_ids = current_user.userable.vehicles.pluck(:id)
      return forbidden unless allowed_ids.include?(@booking.vehicle_id)
    end
  end

  def booking_params
    params.require(:booking).permit(:vehicle_id, :start_location, :end_location, :price, :booking_date, :start_time)
  end

  def driver_booking_params
    params.require(:booking).permit(:status, :start_time, :end_time, :ride_status)
  end
end
