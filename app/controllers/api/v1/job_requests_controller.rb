module Api::V1
  class JobRequestsController < Api::BaseApiController
    self.login_user_type = :user

    before_action :set_job_request, only: [:show, :destroy, :update, :accept, :reject]
    before_action :set_job, only: [:show, :destroy, :update, :accept, :reject]
    before_action :check_actor, only: [:accept, :reject]

    def index
      @job_requests = current_user.job_requests
      respond_with @job_requests, each_serializer: JobRequestSerializer, base_url: request.base_url, status: 200
    end

    def show
      respond_with @job_request, serializer: JobRequestSerializer, base_url: request.base_url, status: 200
    end

    def create
      @job_request      = JobRequest.new(job_request_params)
      @job_request.user = current_user
      if @job_request.save
        render json: @job_request, serialize: JobRequestSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @job_request.errors.full_messages }, status: 422
      end
    end

    def update
      if @job_request.update(job_request_params)
        render json: @job_request, serialize: JobRequestSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @job_request.errors.full_messages }, status: 422
      end
    end

    def destroy
      @job_request.destroy
      render json: @job_request, serialize: JobRequestSerializer, base_url: request.base_url, status: 204
    end

    def accept
      accepted_message = params[:accepted_message].blank? ? "Job owner accepted your job request on job #{@job.title}" : params[:accepted_message]
      rejected_message = params[:rejected_message].blank? ? "Sorry, we decide to reject your job request for job #{@job.title}" : params[:rejected_message]

      if @job_request.pending?
        @job_request.accept!
        @job_request.reload
        @job_request.reject_another_job_requests(accepted_message, rejected_message)
        render json: @job_request, serialize: JobRequestSerializer, base_url: request.base_url, status: 200
      else
        render json: {message: "You already #{@job_request.status} this job request"}, status: 422
      end

    end

    def reject
      rejected_message = params[:rejected_message].blank? ? "Sorry, we decide to reject your job request for job #{@job.title}" : params[:rejected_message]


      if @job_request.pending?
        @job_request.reject!
        @job_request.reload
        @job_request.rejected_message(rejected_message)
        render json: @job_request, serialize: JobRequestSerializer, base_url: request.base_url, status: 200
      else
        render json: {message: "You already #{@job_request.status} this job request"}, status: 422
      end
    end

    private

    def set_job_request
      @job_request = JobRequest.find(params[:id])
    end

    def job_request_params
      params.require(:job_request).permit(:id, :job_id, :status)
    end

    def check_actor
      render json: {error: "Only Job owner allowed to access this page. "}, status: 401 and return unless @job.ownerable.eql?(current_user)
    end

    def set_job
      @job = @job_request.job
    end
  end
end