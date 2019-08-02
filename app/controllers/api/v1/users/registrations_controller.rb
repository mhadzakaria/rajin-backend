module Api::V1::Users
  class RegistrationsController < Devise::RegistrationsController
    include Api::ApiAuthentication
    respond_to :json

    self.login_user_type = :user

    skip_before_action :check_login_time, only: %i[create]
    skip_before_action :authenticate_scope!, only: %i[update]

    def create
      build_resource(sign_up_params)
      resource.save

      if resource.persisted?

        if params[:picture].present?
          picture = resource.build_picture(picture_params)
          # picture.pictureable = resource
          picture.save
        end

        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          render json: resource, serializer: UserSerializer, base_url: request.base_url, status: 200 and return
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          render json: resource, serializer: UserSerializer, base_url: request.base_url, status: 200 and return
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

    def update
      if current_user.update(account_update_params)
        if params[:picture].present?
          picture            = current_user.picture || current_user.build_picture
          picture.attributes = picture_params
          # picture.pictureable = current_user
          picture.save
        end

        render json: current_user, serializer: UserSerializer, base_url: request.base_url, status: 200 and return
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

      def picture_params
        params.require(:picture).permit(:id, :pictureable_type, :pictureable_id, :file_url, :file_type, :user_id)
      end

      def user_params
        # User skills
        if params[:user][:skill_ids].present?
          params[:user][:skill_ids] = params[:user][:skill_ids].split(',').map(&:to_i)
        end
        
        # Location Coordinate
        params[:user][:latitude]  = params[:user][:coordinates][:latitude] rescue 0.0
        params[:user][:longitude] = params[:user][:coordinates][:longitude] rescue 0.0

        lat  = params[:user][:latitude]
        long = params[:user][:longitude]
        geo_localization = "#{lat},#{long}"
        query = Geocoder.search(geo_localization).first
        params[:user][:full_address] = query.display_name if query.present?

        return [:nickname, :first_name, :last_name, :phone_number, :date_of_birth, :gender, :full_address, :city, :postcode, :state, :country, :latitude, 
                :longitude, :user_type, :access_token, :email, :password, :password_confirmation, :current_password, :uuid, :description, :twitter,
                :facebook, :linkedin, skill_ids: []
               ]
      end
  end
end