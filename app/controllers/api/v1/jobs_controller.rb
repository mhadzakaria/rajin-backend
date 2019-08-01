module Api::V1
  class JobsController < Api::BaseApiController
    before_action :set_job, only: [:show, :destroy, :update, :on_progress, :complete, :incomplete, :applicant]

    def index
      @jobs = Job.all
      respond_with @jobs, each_serializer: JobSerializer, status: 200
    end

    def show
      respond_with @job, serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def create
      @job = Job.new(job_params)
      @job.ownerable = current_person
      if @job.save
        if params[:pictures].present?
          files = params[:pictures][:files]
          files.try(:each) do |file|
            picture = @job.pictures.build(picture_params)
            picture.file_url = file[:file_url]
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
          files = params[:pictures][:files]
          files.try(:each) do |file|
            picture = @job.pictures.build(picture_params)
            picture.file_url = file[:file_url]
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
      if params[:search].present?
        if params[:search][:skill_ids].present?
          params[:search][:skill_ids] = params[:search][:skill_ids].split(',').map(&:to_i)
        end

        @jobs = Job.filter(current_person, params[:search])
        render json: @jobs, each_serializer: JobSerializer, status: 200
      else
        @jobs = Job.all
        render json: @jobs, each_serializer: JobSerializer, status: 200
      end
    end

    def filter_user_or_company
      if params[:search].present?
        if params[:search][:user_id].present?
          @jobs = Job.where(ownerable_type: "User", ownerable_id: params[:search][:user_id])
        elsif params[:search][:company_id].present?
          users = User.where(company_id: params[:search][:company_id])
          @jobs = Job.filter_user_or_company(users)
        else
          @jobs = Job.where(ownerable_type: "User")
        end

        if params[:search][:completed].present?
          if @jobs.present?
            @jobs = Job.filter_completed_jobs(@jobs)
          end
        end
      else
        @jobs = Job.where(ownerable_type: "User")
      end

      render json: @jobs, each_serializer: JobSerializer, status: 200
    end

    def verified_jobs
      verified_comp = Company.verified
      verified_user = verified_comp.map{ |vc| vc.users }.flatten
      @jobs = verified_user.map{ |vu| vu.jobs }.flatten

      render json: @jobs, each_serializer: JobSerializer, status: 200
    end

    def normal_jobs
      unverifi_comp = Company.not_verified
      unverifi_user = unverifi_comp.map{ |uc| uc.users }.flatten
      @jobs = unverifi_user.map{ |uu| uu.jobs }.flatten

      uwithout_comp = User.where(company: nil)
      @jobs = uwithout_comp.map{ |us| us.jobs }.flatten + @jobs

      render json: @jobs, each_serializer: JobSerializer, status: 200
    end

    def pending
      @jobs = Job.pending
      render json: @jobs
    end

    def completed
      @jobs = Job.completed
      render json: @jobs
    end

    def accepted
      @jobs = Job.accepted
      render json: @jobs
    end

    def applicant
      @applicants = @job.job_requests.map(&:user)
      render json: @applicants, applicant: true, each_serializer: UserSerializer, status: 200
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

      params.require(:job).permit(:job_category_id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode,:state, :country, :start_date, :end_date, :latitude, :longitude, :status, :ownerable_type, :ownerable_id, skill_ids: [])
    end
  end
end