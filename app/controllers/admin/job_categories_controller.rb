module Admin
  class JobCategoriesController < ApplicationController
    before_action :set_job_category, only: [:show, :edit, :update, :destroy]
    before_action :get_collection, only: [:new, :edit, :create, :update]

    include Pundit::Authorization

    def index
      @q = JobCategory.ransack(params[:q])
      @job_categories = @q.result.page(params[:page])
    end

    def show
    end

    def new
      @job_category = JobCategory.new
    end

    def edit
    end

    def create
      @job_category = JobCategory.new(job_category_params)

      respond_to do |format|
        if @job_category.save
          format.html { redirect_to admin_job_categories_path, notice: 'Job category was successfully created.' }
          format.json { render :show, status: :created, location: @job_category }
        else
          format.html { render :new }
          format.json { render json: @job_category.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @job_category.update(job_category_params)
          format.html { redirect_to admin_job_categories_path, notice: 'Job category was successfully updated.' }
          format.json { render :show, status: :ok, location: @job_category }
        else
          format.html { render :edit }
          format.json { render json: @job_category.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @job_category.destroy
      respond_to do |format|
        format.html { redirect_to admin_job_categories_path, notice: 'Job category was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_job_category
        @job_category = JobCategory.find(params[:id])
      end

      def job_category_params
        params.require(:job_category).permit(:name, :parent_id)
      end

      def get_collection
        @other_categories = JobCategory.where.not(id: @job_category.try(:id)).map{|category| [category.name, category.id]}
      end
  end
end
