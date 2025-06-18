class RatingsController < ApplicationController
  def new
    @rateable_type = params[:rateable_type]
    @rateable_id = params[:rateable_id]
    @rating = Rating.new
  end

  def create
    @rating = Rating.new(rating_params)
    @rating.user_id = session[:user_id]

    if @rating.save
      Reward.create(user_id: @rating.user_id, points: 10, reward_type: "Rating Bonus")
      redirect_to home_path, notice: "Thank you for your feedback!"
    else
      flash.now[:alert] = "Rating failed. Please try again."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:stars, :comments, :rateable_type, :rateable_id)
  end
end
