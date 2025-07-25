# frozen_string_literal: true

class RatingsController < ApplicationController
  before_action :set_user_id
  before_action :set_rating, only: %i[edit update destroy]
  before_action :check_duplicate, only: :create

  def new
    @rating = Rating.new(
      rateable_type: params[:rateable_type],
      rateable_id: params[:rateable_id]
    )
  end

  def create
    @rating = Rating.new(rating_params)
    @rating.user_id = @user_id

    if @rating.save
      flash[:notice] = 'Rating submitted successfully!'
      redirect_back fallback_location: customer_ride_history_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @rating.update(rating_params)
      flash[:notice] = 'Rating updated successfully!'
      redirect_back fallback_location: customer_ride_history_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rating.destroy
    flash[:notice] = 'Rating deleted successfully!'
    redirect_back fallback_location: customer_ride_history_path
  end

  private

  def set_user_id
    @user_id = current_user.id
  end

  def set_rating
    @rating = Rating.find(params[:id])
  end

  def check_duplicate
    if Rating.exists?(user_id: @user_id, rateable_type: rating_params[:rateable_type],
                      rateable_id: rating_params[:rateable_id])
      redirect_to bookings_path, alert: 'You have already rated this.' and return
    end
  end

  def rating_params
    params.require(:rating).permit(:rateable_type, :rateable_id, :stars, :comments)
  end
end
