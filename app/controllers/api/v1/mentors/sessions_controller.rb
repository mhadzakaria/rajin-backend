module Api::V1::Mentors
  class SessionsController < Devise::SessionsController
    include Api::ApiAuthentication
    respond_to :json

    self.login_user_type = :mentor

    before_action :check_login_time, only: %i[show]

    def show
      respond_with current_mentor, serializer: MentorSerializer, status: 200
    end

    def create
      self.resource = Mentor.find_by_email(sign_in_params[:email])
      if resource && resource.valid_password?(sign_in_params[:password])
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        resource.generate_access_token
        resource.save
        render json: resource, serializer: MentorSerializer, status: 200
      else
        render json: {message: "Unauthorized! Please check your username and password!"}, status: 401
      end
    end

    protected

    def configure_sign_in_params
      params.require(:mentor).permit(:email, :password)
    end

    def resource_name
      return devise_mapping.name.to_s.gsub("api_v1_", "").to_sym
    end
  end
end
