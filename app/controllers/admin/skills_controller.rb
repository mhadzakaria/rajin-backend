module Admin
  class SkillsController < ApplicationController
    before_action :set_skill, only: [:show, :edit, :update, :destroy]

    include Pundit::Authorization

    def index
      @q = Skill.ransack(params[:q])
      @skills = @q.result.page(params[:page]).order(:name)
    end

    def show
    end

    def new
      @skill = Skill.new
      @picture = @skill.build_picture
    end

    def edit
    end

    def create
      @skill = Skill.new(skill_params)

      respond_to do |format|
        if @skill.save
          add_picture if params[:skill][:picture][:file_url].present?
          format.html { redirect_to admin_skills_path, notice: 'Skill was successfully created.' }
          format.json { render :show, status: :created, location: @skill }
        else
          format.html { render :new }
          format.json { render json: @skill.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @skill.update(skill_params)
          add_picture if params[:skill][:picture][:file_url].present?
          format.html { redirect_to admin_skills_path, notice: 'Skill was successfully updated.' }
          format.json { render :show, status: :ok, location: @skill }
        else
          format.html { render :edit }
          format.json { render json: @skill.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @skill.destroy
      respond_to do |format|
        format.html { redirect_to admin_skills_path, notice: 'Skill was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def add_picture
        picture = @skill.build_picture
        picture.file_url  = params[:skill][:picture][:file_url]
        picture.file_type = params[:skill][:picture][:file_type]
        picture.save
      end

      def set_skill
        @skill = Skill.find(params[:id])
      end

      def skill_params
        params.require(:skill).permit(:name)
      end
  end
end