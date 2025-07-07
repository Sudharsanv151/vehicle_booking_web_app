module Api
  class BaseController < ApplicationController
    
    protect_from_forgery with: :null_session
    
    before_action :doorkeeper_authorize!
    

    def current_user
      @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def require_customer!
      unless current_user&.userable_type=="Customer"
        render json: {error: "Only customers are allowed to perform this action"}, status: :forbidden
      end
    end

    def require_driver!
      unless current_user&.userable_type=="Driver"
        render json: {error: "Only drivers are allowed to perform this action"}, status: :forbidden
      end
    end

  end
end