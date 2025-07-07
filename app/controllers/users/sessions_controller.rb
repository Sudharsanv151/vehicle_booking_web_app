module Users
  class SessionsController < Devise::SessionsController
    def create
      user = User.find_by(email: params[:user][:email])

      if user&.valid_password?(params[:user][:password])
        expected_role = params[:role].to_s.downcase
        actual_role   = user.userable_type.to_s.downcase

        if expected_role.present? && expected_role != actual_role
          flash[:alert] = "You are not registered as a #{expected_role.capitalize}."
          redirect_to new_user_session_path(role: expected_role) and return
        end

        self.resource = warden.set_user(user)
        sign_in(resource_name, resource)
        redirect_to after_sign_in_path_for(resource)
      else
        flash[:alert] = "Invalid email or password."
        redirect_to new_user_session_path(role: params[:role])
      end
    end
  end
end
