module Users
  class RegistrationsController < Devise::RegistrationsController
    
    before_action :configure_permitted_parameters, only: [:create]
    before_action :redirect_if_signed_in, only: [:select_role, :new]

    def select_role
      sign_out(current_user) if user_signed_in?
      reset_session
      store_location_for(:user, nil)
      # flash[:notice] = "You have been logged out."
    end

    def new
      @role = params[:role]
      build_resource
    end

    def create
      @role = params[:role].to_s.downcase
      build_resource(sign_up_params)

      case @role
      when 'customer'
        customer = Customer.new(location: params[:location])
        unless customer.save
          flash.now[:alert] = customer.errors.full_messages.to_sentence.presence || "Customer information is invalid."
          render :new, status: :unprocessable_entity and return
        end
        resource.userable = customer

      when 'driver'
        driver = Driver.new(licence_no: params[:licence_no])
        unless driver.save
          flash.now[:alert] = driver.errors.full_messages.to_sentence.presence || "Driver information is invalid."
          render :new, status: :unprocessable_entity and return
        end
        resource.userable = driver

      else
        flash.now[:alert] = "Invalid role selected."
        render :new, status: :unprocessable_entity and return
      end

      if resource.save
        sign_up(resource_name, resource)
        redirect_to home_path, notice: "Welcome #{resource.name}!"
      else
        flash.now[:alert] = resource.errors.full_messages.to_sentence.presence || "Signup failed."
        clean_up_passwords resource
        render :new, status: :unprocessable_entity
      end
    end


    protected

    def after_sign_up_path_for(resource)
      redirect_to home_path
    end

    def redirect_if_signed_in
      redirect_to home_path, alert: "You are already signed in." if user_signed_in?
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :mobile_no, :location, :licence_no])
    end
  end
end
