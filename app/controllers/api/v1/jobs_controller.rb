module Api::V1
  class JobsController < Api::BaseApiController
    before_action :set_job, only: [:show, :destroy, :update]

    def index
      @jobs = Job.all
      respond_with @jobs, each_serializer: JobSerializer, status: 200
    end

    def show
      respond_with @job, serializer: JobSerializer, status: 200
    end

    def create
      @job = Job.new(job_params)
      if @job.save
        render json: @job, serialize: JobSerializer, status: 200
      else
        render json: { error: @job.errors.full_messages }, status: 422
      end
    end

    def update
      if @job.update(job_params)
        render json: @job, serialize: JobSerializer, status: 200
      else
        render json: { error: @job.errors.full_messages }, status: 422
      end
    end

    def destroy
      @job.destroy
      render json: @job, serialize: JobSerializer, status: 204
    end

    private

    def set_job
      @job = Job.find(params[:id])
    end

    def job_params
      params[:job][:skill_ids] = params[:job][:skill_ids].split(',').map(&:to_i)
      params.require(:job).permit(:user_id, :job_category_id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode,:state, :country, :start_date, :end_date, :latitude, :longitude, :status, skill_ids: [])
    end
  end
end