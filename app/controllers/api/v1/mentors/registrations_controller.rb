module Api::V1::Mentors
  class RegistrationsController < Devise::RegistrationsController
    include Api::ApiAuthentication
    respond_to :json
    
    self.login_user_type = :mentor

    skip_before_action :check_login_time, only: %i[create]
    skip_before_action :authenticate_scope!, only: %i[update]

    def create
      build_resource(sign_up_params)
      resource.save

      if resource.persisted?

        if params[:picture].present?
          picture = resource.build_picture(picture_params)
          picture.save
        end

        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          # sign_up(resource_name, resource)
          render json: resource, serializer: MentorSerializer, base_url: request.base_url, status: 200 and return
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          render json: resource, serializer: MentorSerializer, base_url: request.base_url, status: 200 and return
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

    def update
      if current_mentor.update(account_update_params)
        if params[:picture].present?
          picture = current_mentor.picture || current_mentor.build_picture
          picture.attributes = picture_params
          picture.save
        end

        render json: current_mentor, serializer: MentorSerializer, base_url: request.base_url, status: 200 and return
      else
        clean_up_passwords current_mentor
        set_minimum_password_length
        respond_with current_mentor
      end
    end


    protected
      def resource_name
        devise_mapping.name.to_s.gsub("api_v1_", "").to_sym
      end

    private
      def sign_up_params
        params.require(:mentor).permit(*mentor_params)
      end

      def account_update_params
        params.require(:mentor).permit(*mentor_params)
      end

      def picture_params
        params.require(:picture).permit(:id, :pictureable_type, :pictureable_id, :file_url, :file_type)
      end

      def mentor_params
        if params[:mentor][:skill_ids].present?
          params[:mentor][:skill_ids] = params[:mentor][:skill_ids].split(',').map(&:to_i)
        end

        # Location Coordinate
        params[:mentor][:latitude]  = params[:mentor][:coordinates][:latitude] rescue 0.0
        params[:mentor][:longitude] = params[:mentor][:coordinates][:longitude] rescue 0.0

        lat  = params[:mentor][:latitude]
        long = params[:mentor][:longitude]
        geo_localization = "#{lat},#{long}"
        query = Geocoder.search(geo_localization).first
        params[:mentor][:full_address] = query.display_name if query.present?

        return [:nickname, :first_name, :last_name, :phone_number, :date_of_birth, :gender, :full_address, :city, :postcode, :state, :country, :latitude, 
                :longitude, :position, :mentor_type, :access_token, :email, :password, :password_confirmation, :current_password, :uuid, skill_ids: []
               ]
      end
  end
end
