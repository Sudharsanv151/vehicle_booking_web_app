class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def after_sign_in_path_for(resource)
    session[:user_id] = resource.id       
    home_path
  end

  def after_sign_up_path_for(resource)
    session[:user_id] = resource.id
    home_path
  end
end
