module Api::V1
  class SkillsController < Api::BaseApiController
    before_action :set_skill, only: [:show, :destroy, :update]

    def index
      @skills = Skill.all
      respond_with @skills, each_serializer: SkillSerializer, status: 200
    end

    def show
      respond_with @skill, serializer: SkillSerializer, status: 200
    end

    def create
      @skill = Skill.new(skill_params)
      if @skill.save
        render json: @skill, serialize: SkillSerializer, status: 200
      else
        render json: { error: @skill.errors.full_messages }, status: 422
      end
    end

    def update
      if @skill.update(skill_params)
        render json: @skill, serialize: SkillSerializer, status: 200
      else
        render json: { error: @skill.errors.full_messages }, status: 422
      end
    end

    def destroy
      @skill.destroy
      render json: @skill, serialize: SkillSerializer, status: 204
    end

    private

    def set_skill
      @skill = Skill.find(params[:id])
    end

    def skill_params
      params.require(:skill).permit(:name, :user_id, :job_id)
    end
  end
end