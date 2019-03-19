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
        if params[:pictures].present?
          params[:pictures][:files].each do |file|
            picture = @job.pictures.build(picture_params)
            picture.file_url = file[:file_url]
            picture.user_id = @job.user_id
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
        if params[:pictures].present?
          params[:pictures][:files].each do |file|
            picture = @job.pictures.build(picture_params)
            picture.file_url = file[:file_url]
            picture.user_id = @job.user_id
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

    def filter
      skill_ids = []

      if params[:search].present?
        if params[:search][:skill_ids].present?
          params[:search][:skill_ids] = params[:search][:skill_ids].split(',').map(&:to_i)
          skill_ids                   = params[:search][:skill_ids]
        end

        user     = current_user
        amount   = params[:search][:amount] if params[:search][:amount].present?
        distance = params[:search][:distance] if params[:search][:distance].present?
        verified = params[:search][:verified] if params[:search][:verified].present?

        @jobs = Job.filter(user, skill_ids, amount, distance, verified)
        respond_with @jobs, each_serializer: JobSerializer, status: 200
      else
        @jobs = Job.all
        respond_with @jobs, each_serializer: JobSerializer, status: 200
      end
    end

    private

    def set_job
      @job = Job.find(params[:id])
    end

    def picture_params
      params.require(:pictures).permit(:id, :pictureable_type, :pictureable_id, :file_type, :file_url, files: [])
    end

    def job_params
      if params[:job][:skill_ids].present?
        params[:job][:skill_ids] = params[:job][:skill_ids].split(',').map(&:to_i)
      end

      params.require(:job).permit(:user_id, :job_category_id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode,:state, :country, :start_date, :end_date, :latitude, :longitude, :status, skill_ids: [])
    end
  end
end