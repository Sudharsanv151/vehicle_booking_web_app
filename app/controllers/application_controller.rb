# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_root_path
    elsif resource.is_a?(User)
      home_path
    else
      super
    end
  end

  def after_sign_up_path_for(resource)
    if resource.is_a?(User)
      session[:user_id] = resource.id
      home_path
    else
      super
    end
  end
end
