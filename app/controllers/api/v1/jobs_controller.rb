module Api::V1
  class JobsController < Api::BaseApiController
    before_action :set_job, only: [:show, :destroy, :update, :on_progress, :complete, :incomplete, :applicant, :set_to_promoted]
    before_action :set_company_or_user, only: [:my_job_pending, :my_job_completed, :my_job_on_progress, :completed, :accepted]

    def index
      @jobs = Job.all.order(created_at: :desc).page(params[:page] || 1)
      respond_with @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
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
        render json: @job, serialize: JobSerializer, base_url: request.base_url, status: 200
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
        render json: @job, serialize: JobSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @job.errors.full_messages }, status: 422
      end
    end

    def destroy
      @job.destroy
      render json: @job, serialize: JobSerializer, base_url: request.base_url, status: 204
    end

    def complete
      @job.complete!
      render json: @job, serialize: JobSerializer, base_url: request.base_url, status: 200
    end

    def on_progress
      @job.on_progress!
      render json: @job, serialize: JobSerializer, base_url: request.base_url, status: 200
    end

    def incomplete
      @job.incomplete!
      render json: @job, serialize: JobSerializer, base_url: request.base_url, status: 200
    end

    def filter
      if params[:search].present?
        if params[:search][:skill_ids].present?
          params[:search][:skill_ids] = params[:search][:skill_ids].split(',').map(&:to_i)
        end

        @jobs = Job.filter(current_person, params[:search]).page(params[:page] || 1)
        render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
      else
        @jobs = Job.pending.order(created_at: :desc).page(params[:page] || 1)
        render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
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

      begin
        @jobs = @jobs.pending
      rescue Exception => e
        @jobs = @jobs.select { |j| j.status.eql?('pending') }
      end

      @jobs = @jobs.order(created_at: :desc).page(params[:page] || 1)
      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def verified_jobs
      verified_comp = Company.verified
      verified_user = verified_comp.map{ |vc| vc.users }.flatten
      @jobs = Job.pending.where(ownerable: verified_user).order(created_at: :desc).page(params[:page] || 1)

      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def normal_jobs
      unverifi_comp = Company.not_verified
      unverifi_user = unverifi_comp.map{ |uc| uc.users }.flatten
      # @jobs = unverifi_user.map{ |uu| uu.jobs }.flatten

      uwithout_comp = User.where(company: nil)
      # @jobs = uwithout_comp.map{ |us| us.jobs }.flatten + @jobs

      @jobs = Job.pending.where(ownerable: unverifi_user + uwithout_comp).order(created_at: :desc).page(params[:page] || 1)

      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def my_job_pending
      if params[:company_id].present?
        users = User.where(company_id: params[:company_id])
        @jobs = Job.filter_user_or_company(users)
      else
        if @user.present?
          @jobs = @user.jobs
        else
          @jobs = current_person.jobs
        end
      end

      @jobs = @jobs.pending.order(created_at: :desc).page(params[:page] || 1).order(:created_at)
      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def my_job_on_progress
      if @user.present?
        @jobs = @user.jobs
      else
        @jobs = current_person.jobs
      end

      @jobs = @jobs.accepted.order(created_at: :desc).page(params[:page] || 1)
      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def my_job_completed
      if @user.present?
        @jobs = @user.jobs
      else
        @jobs = current_person.jobs
      end

      @jobs = @jobs.completed.order(created_at: :desc).page(params[:page] || 1)
      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def completed
      set_job_requests
      @jobs = Job.where(id: @job_requests.map(&:job_id)).completed.order(created_at: :desc).page(params[:page] || 1)
      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def accepted
      set_job_requests
      @jobs = Job.where(id: @job_requests.map(&:job_id)).accepted.order(created_at: :desc).page(params[:page] || 1)
      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def applicant
      @job_requests = @job.job_requests.not_rejected.order(created_at: :desc)
      render json: @job_requests, each_serializer: JobRequestSerializer, base_url: request.base_url, status: 200
    end

    def promoted_jobs
      # add filter is_promoted
      @jobs = Job.is_promoted.order(created_at: :desc).page(params[:page] || 1)
      render json: @jobs, each_serializer: JobSerializer, base_url: request.base_url, status: 200
    end

    def set_to_promoted
      @job.update(is_promoted: true)
      render json: @job, serialize: JobSerializer, base_url: request.base_url, status: 200
    end

    private

    def set_company_or_user
      if params[:user_id]
        @user = User.find(params[:user_id])
      end

      @user
    end

    def set_job_requests
      if @user.present?
        @job_requests = @user.job_requests.accepted
      else
        @job_requests = current_person.job_requests.accepted
      end

      @job_requests
    end

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

      params.require(:job).permit(:job_category_id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode,:state, :country, :start_date, :end_date, :latitude, :longitude, :status, :ownerable_type, :ownerable_id, :duration, :is_promoted, :duration_type, skill_ids: [])
    end
  end
end