class UsersController < ApplicationController

  before_action :set_user, only: [:profile, :edit, :update, :destroy]

  def select_role
  end

  def profile
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
    flash[:notice]="User created successfully!"
    session[:user_id] = @user.id
    redirect_to home_path
  end

  def home
    @user = User.find_by(id: session[:user_id])
    unless @user
      flash[:alert] = "User not found!!"
      redirect_to select_role_path
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:notice]="Profile updated!!"
      redirect_to profile_path
    else
      flash[:alert]="Error in updating profile"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    flash[:notice]="Account deleted successfully!"
    reset_session
    redirect_to select_role_path
  end

  private

  def set_user
    @user = User.find_by(id:session[:user_id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :mobile_no, :password)
  end

end
