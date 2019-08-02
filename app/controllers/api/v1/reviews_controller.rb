module Api::V1
  class ReviewsController < Api::BaseApiController
    before_action :set_job_request, only: [:create, :index, :show, :destroy, :update]
    before_action :set_review, only: [:show, :destroy, :update]

    def index
      @reviews = @job.reviews
      respond_with @reviews, each_serializer: ReviewSerializer, base_url: request.base_url, status: 200
    end

    def show
      respond_with @review, serializer: ReviewSerializer, base_url: request.base_url, status: 200
    end

    def create
      @review = Review.new(review_params)
      @review.job_id = @job.id
      @review.save
      if @review.save
        render json: @review, serialize: ReviewSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @review.errors.full_messages }, status: 422
      end
    end

    def update
      if @review.update(review_params)
        render json: @review, serialize: ReviewSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @review.errors.full_messages }, status: 422
      end
    end

    def destroy
      @review.destroy
      render json: @review, serialize: ReviewSerializer, base_url: request.base_url, status: 204
    end

    private

    def set_review
      @review = @job.reviews.find(params[:id])
    end

    def set_job_request
      @job_request = JobRequest.find(params[:job_request_id])
      @job = @job_request.job
    end

    def review_params
      params.require(:review).permit(:user_id, :sender_id, :job_id, :comment, :rate)
    end
  end
end