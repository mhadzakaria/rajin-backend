module Api::V1
  class JobsController < Api::BaseApiController
    before_action :set_job, only: [:show, :destroy, :update, :on_progress, :complete, :incomplete]

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
        if params[:job][:pictures].present?
          params[:job][:pictures].each do |file|
            picture = @job.pictures.build(file_url: file[:file_url], user_id: @job.user_id)
            picture.save
          end
        end
        render json: @job, serialize: JobSerializer, status: 200
      else
        render json: { error: @job.errors.full_messages }, status: 422
      end
    end

    def update
      if @job.update(job_params)
        if params[:job][:pictures].present?
          params[:job][:pictures].each do |file|
            picture = @job.pictures.build(file_url: file[:file_url], user_id: @job.user_id)
            picture.save
          end
        end
        render json: @job, serialize: JobSerializer, status: 200
      else
        render json: { error: @job.errors.full_messages }, status: 422
      end
    end

    def destroy
      @job.destroy
      render json: @job, serialize: JobSerializer, status: 204
    end

    def complete
      @job.complete!
      render json: @job, serialize: JobSerializer, status: 200
    end

    def on_progress
      @job.on_progress!
      render json: @job, serialize: JobSerializer, status: 200
    end

    def incomplete
      @job.incomplete!
      render json: @job, serialize: JobSerializer, status: 200
    end


    private

    def set_job
      @job = Job.find(params[:id])
    end

    def picture_params
      params.require(:picture).permit(:id, :pictureable_type, :pictureable_id, :file_type, :file_url, files: [])
    end

    def job_params
      params[:job][:skill_ids] = params[:job][:skill_ids].split(',').map(&:to_i)
      params.require(:job).permit(:user_id, :job_category_id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode,:state, :country, :start_date, :end_date, :latitude, :longitude, :status, skill_ids: [])
    end
  end
end