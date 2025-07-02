module Api
  class BaseController < ApplicationController
    
    protect_from_forgery with: :null_session
    # before_action :authenticate_user!
    # respond_to :json
  end
end