module Api::V1::Users
  class SessionsController < Devise::SessionsController
    include Api::ApiAuthentication
    respond_to :json

    self.login_user_type = :user

    before_action :check_login_time, only: %i[show]

    def show
      respond_with current_user, serializer: UserSerializer, base_url: request.base_url, status: 200
    end

    def create
      self.resource = User.find_by_email(sign_in_params[:email])
      if resource && resource.valid_password?(sign_in_params[:password])
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        resource.generate_access_token
        resource.save
        render json: resource, serializer: UserSerializer, base_url: request.base_url, status: 200
      else
        render json: {message: "Unauthorized! Please check your username and password!"}, status: 401
      end
    end

    protected
      def resource_name
        devise_mapping.name.to_s.gsub("api_v1_", "").to_sym
      end

    private
      def sign_in_params
        params.require(:user).permit(:email, :password)
      end

  end
end