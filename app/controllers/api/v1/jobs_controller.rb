module Api::V1
  class JobsController < Api::BaseApiController

    def index
      jobs = Job.all
      respond_with jobs, each_serializer: JobSerializer, status: 200
    end

    def show
    	job = Job.find_by_id(params[:id])
      respond_with job, serializer: JobSerializer, status: 200
    end

  end
end