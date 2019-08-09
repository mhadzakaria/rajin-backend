module Api::V1
  class JobCategoriesController < Api::BaseApiController
    before_action :set_job_category, only: [:show, :destroy, :update]

    def index
      @job_categories = JobCategory.all
      respond_with @job_categories, each_serializer: JobCategorySerializer, status: 200
    end

    def show
      respond_with @job_category, serializer: JobCategorySerializer, status: 200
    end

    def create
      @job_category = JobCategory.new(job_category_params)
      if @job_category.save
        render json: @job_category, serialize: JobCategorySerializer, status: 200
      else
        render json: { error: @job_category.errors.full_messages }, status: 422
      end
    end

    def update
      if @job_category.update(job_category_params)
        render json: @job_category, serialize: JobCategorySerializer, status: 200
      else
        render json: { error: @job_category.errors.full_messages }, status: 422
      end
    end

    def destroy
      @job_category.destroy
      render json: @job_category, serialize: JobCategorySerializer, status: 204
    end

    def top_ten
      @job_categories = JobCategory.top_ten
      respond_with @job_categories, each_serializer: JobCategorySerializer, status: 200
    end

    private

    def set_job_category
      @job_category = JobCategory.find(params[:id])
    end

    def job_category_params
      params.require(:job_category).permit(:name, :parent_id)
    end
  end
end