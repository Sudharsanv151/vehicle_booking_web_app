class UsersController < ApplicationController
  def select_role
  end

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
  end
end