class RatingsController < ApplicationController
  
  before_action :set_user_id
  before_action :check_duplicate,only: :create

  def new
    @rating = Rating.new
  end

  def create
    @rating = Rating.new(rating_params)
    @rating.user_id = @user_id

    if @rating.save
      flash[:notice] = "Rating submitted successfully!"
      Reward.create(user_id: @rating.user_id, points: 10, reward_type: "Rating Bonus")
      redirect_to bookings_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_user_id
    @user_id = session[:user_id]
  end

  def check_duplicate
    if Rating.exists?(user_id: @user_id, rateable_type: rating_params[:rateable_type], rateable_id: rating_params[:rateable_id])
      redirect_to bookings_path, alert: "You have already rated this." and return
    end
  end

  def rating_params
    params.require(:rating).permit(:rateable_type, :rateable_id, :stars, :comments)
  end
end
