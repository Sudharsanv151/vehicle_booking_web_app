# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session

    def current_user
      return nil unless doorkeeper_token
      return nil if client_credentials_token?

      @current_user ||= User.find_by(id: doorkeeper_token.resource_owner_id)
    end

    def client_credentials_token?
      doorkeeper_token&.application.present? && doorkeeper_token&.resource_owner_id.nil?
    end

    def customer?
      current_user&.userable_type == 'Customer'
    end

    def driver?
      current_user&.userable_type == 'Driver'
    end

    def forbidden
      render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
    end
  end
end
