module Api::V1
  class SkillsController < Api::BaseApiController
    before_action :set_skill, only: [:show, :destroy, :update]

    def index
      @skills = Skill.all
      respond_with @skills, each_serializer: SkillSerializer, base_url: request.base_url, status: 200
    end

    def show
      respond_with @skill, serializer: SkillSerializer, base_url: request.base_url, status: 200
    end

    def create
      @skill = Skill.new(skill_params)
      if @skill.save
        if params[:picture].present?
          picture = @skill.build_picture(picture_params)
          picture.save
        end

        render json: @skill, serialize: SkillSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @skill.errors.full_messages }, status: 422
      end
    end

    def update
      if @skill.update(skill_params)
        if params[:picture].present?
          picture            = @skill.picture || @skill.build_picture
          picture.attributes = picture_params
          picture.save
        end

        render json: @skill, serialize: SkillSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @skill.errors.full_messages }, status: 422
      end
    end

    def destroy
      @skill.destroy
      render json: @skill, serialize: SkillSerializer, base_url: request.base_url, status: 204
    end

    private

    def set_skill
      @skill = Skill.find(params[:id])
    end

    def picture_params
      params.require(:picture).permit(:id, :pictureable_type, :pictureable_id, :file_url, :file_type)
    end

    def skill_params
      params.require(:skill).permit(:name)
    end
  end
end