module Api::V1::Users
  class RegistrationsController < Devise::RegistrationsController
    include Api::ApiAuthentication
    respond_to :json
    
    skip_before_action :check_login_time, only: %i[create]
    skip_before_action :authenticate_scope!, only: %i[update]

    def create
      build_resource(sign_up_params)
      resource.save
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          render json: resource, serializer: UserSerializer, status: 200 and return
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          render json: resource, serializer: UserSerializer, status: 200 and return
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

    def update
      if current_user.update(account_update_params)
        render json: current_user, serializer: UserSerializer, status: 200 and return
      else
        clean_up_passwords current_user
        set_minimum_password_length
        respond_with current_user
      end
    end

    protected
      def resource_name
        devise_mapping.name.to_s.gsub("api_v1_", "").to_sym
      end

    private
      def sign_up_params
        params.require(:user).permit(*user_params)
      end

      def account_update_params
        params.require(:user).permit(*user_params)
      end

      def user_params
        # Location Coordinate
        params[:user][:latitude]  = params[:user][:coordinates][:latitude] rescue 0.0
        params[:user][:longitude] = params[:user][:coordinates][:longitude] rescue 0.0

        lat  = params[:user][:latitude]
        long = params[:user][:longitude]
        geo_localization = "#{lat},#{long}"
        query = Geocoder.search(geo_localization).first
        params[:user][:full_address] = query.display_name if query.present?

        return [:nickname, :first_name, :last_name, :phone_number, :date_of_birth, :gender, :full_address, :city, :postcode, :state, :country, :latitude, 
                :longitude, :position, :user_type, :access_token, :email, :password, :password_confirmation, :current_password, :uuid,
                pictures_attributes: [:id, :pictureable_type, :pictureable_id, :file_url, :file_type]
               ]
      end
  end
end