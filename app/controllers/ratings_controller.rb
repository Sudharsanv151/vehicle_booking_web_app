class RatingsController < ApplicationController
  def new
    @rating = Rating.new
  end

  def create
    @rating = Rating.new(rating_params)
    @rating.user_id = session[:user_id]

    if Rating.exists?(user_id: @rating.user_id, rateable_type: @rating.rateable_type, rateable_id: @rating.rateable_id)
      redirect_to home_path, alert: "You have already rated this."
    elsif @rating.save
      Reward.create(user_id: @rating.user_id, points: 10, reward_type: "Rating Bonus")
      redirect_to home_path, notice: "Thanks for rating!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:rateable_type, :rateable_id, :stars, :comments)
  end
end