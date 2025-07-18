class RewardsController < ApplicationController
  def customer_history
    @user = current_user || User.find(session[:user_id])
    
    if @user.userable_type == "Customer"
      @rewards = @user.rewards.order(created_at: :desc).page(params[:page]).per(10)
    else
      redirect_to root_path, alert: "Access denied."
    end
  end
  
end
