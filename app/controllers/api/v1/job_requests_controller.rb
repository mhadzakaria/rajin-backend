module Api::V1
  class JobRequestsController < Api::BaseApiController
    before_action :set_job_request, only: [:show, :destroy, :update]

    def index
      @job_requests = current_user.job_requests
      respond_with @job_requests, each_serializer: JobRequestSerializer, status: 200
    end

    def show
      respond_with @job_request, serializer: JobRequestSerializer, status: 200
    end

    def create
      @job_request = JobRequest.new(job_request_params)
      if @job_request.save
        render json: @job_request, serialize: JobRequestSerializer, status: 200
      else
        render json: { error: @job_request.errors.full_messages }, status: 422
      end
    end

    def update
      if @job_request.update(job_request_params)
        render json: @job_request, serialize: JobRequestSerializer, status: 200
      else
        render json: { error: @job_request.errors.full_messages }, status: 422
      end
    end

    def destroy
      @job_request.destroy
      render json: @job_request, serialize: JobRequestSerializer, status: 204
    end

    private

    def set_job_request
      @job_request = JobRequest.find(params[:id])
    end

    def job_request_params
      params.require(:job_request).permit(:user_id, :job_id, :status)
    end
  end
end