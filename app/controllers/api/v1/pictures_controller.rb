module Api::V1
  class PicturesController < Api::BaseApiController
    def upload
      if params[:upload_pictures].present?
        errors = {}
        params[:upload_pictures].each do |key, val|
          picture           = current_user.uploaded_pictures.new()
          picture.file_url  = val['file_url']
          picture.file_type = val['file_type']
          if !picture.save
            errors[key] = picture.errors
          end
        end
      end

      if errors.blank?
        render json: current_user, serializer: UserSerializer, base_url: request.base_url, status: 200
      else
        render json: errors, status: 400
      end
    end
  end
end