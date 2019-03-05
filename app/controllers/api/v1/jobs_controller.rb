module Api::V1
  class JobsController < Api::BaseApiController
    before_action :set_job, only: [:show]

    def index
      @jobs = Job.all
      respond_with @jobs, each_serializer: JobSerializer, status: 200
    end

    def show
      respond_with @job, serializer: JobSerializer, status: 200
    end

    private

    def set_job
      @job = Job.find(params[:id])
    end

  end
end