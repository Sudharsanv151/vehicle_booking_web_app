class UsersController < ApplicationController
  def select_role; end

  def new
    @role = params[:role]
    @userable = @role == "customer" ? Customer.new : Driver.new
  end

  def create
    @role = params[:role]
    @userable = @role == "customer" ? Customer.create(location: params[:location]) : Driver.create(licence_no: params[:licence_no])

    @user = User.create(
      name: params[:name],
      email: params[:email],
      password: params[:password],
      mobile_no: params[:mobile_no],
      userable: @userable
    )

    session[:user_id] = @user.id
    redirect_to home_path
  end

  def home
    @user = User.find(session[:user_id])
    if @user.userable_type == "Customer"
      @vehicles = Vehicle.includes(:tags, :driver)
      @bookings = @user.bookings.includes(:vehicle, :payment)
    else
      @vehicles = @user.userable.vehicles
      @requests = Booking.joins(:vehicle).where(vehicles: { driver_id: @user.userable.id }, status: false)

      # @requests = Booking.joins(:vehicle).where(vehicles: { driver_id: @user.userable.id }, status: false)
      @approved = Booking.joins(:vehicle).where(vehicles: { driver_id: @user.userable.id }, status: true)

    end
  end
end
