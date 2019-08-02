module Api::V1::Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
   skip_before_action :authenticate_user!

   respond_to :html, :json

    def passthru
      super
    end

    def facebook
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      if request.env["omniauth.auth"].present?
        auth_params = request.env["omniauth.auth"]
      else
        auth_params = params[:user]
      end

      resource = User.from_omniauth(auth_params)

      respond_to do |format|
        if resource.present?
          set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
          sign_in(resource_name, resource)
          resource.generate_access_token
          resource.save

          format.html {sign_in_and_redirect resource, event: :authentication} #this will throw if resource is not activated
          format.json {render json: resource, serializer: UserSerializer, base_url: request.base_url, status: 200}
        else
          session["devise.facebook_data"] = request.env["omniauth.auth"]

          format.html {redirect_to new_user_registration_url} #this will throw if resource is not activated
          format.json {render json: "Invalid authentication data", status: 422}
        end
      end
    end

    def failure
      redirect_to root_path
    end

    protected

      def resource_name
        devise_mapping.name.to_s.gsub("api_v1_", "").to_sym
      end

  end
end