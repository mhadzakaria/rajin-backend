module Admin
  class JobsController < ApplicationController
    before_action :set_job, only: [:show, :edit, :update, :destroy]
    before_action :get_collection, only: [:new, :edit, :create, :update]

    include Pundit::Authorization

    def index
      # filter collection
      @job_categories = JobCategory.all.map{|category|  [category.name, category.id]}
      @statuses       = Job.aasm.states.map{|state| [state.name.to_s.humanize, state.name] }
      @skills         = Skill.all.map{|skill| [skill.name, skill.id]}
      @payment_types  = Job::PAYMENT_TYPE

      @q = Job.ransack(params[:q])
      if params[:q].present?
        skill_field = params[:q][:skill_ids]
        skill_field.delete("")

        skill_field = skill_field.map(&:to_i)
      end

      @jobs = @q.result.page(params[:page])

      if skill_field.present?
        results = []
        skill_field.each do |skill|
          @jobs.each do |job|
            result = job.skill_ids.include?(skill)
            results << job.id if result
          end
        end
        @jobs = Job.where(id: results.uniq).page(params[:page])
      end

      respond_to do |format|
        format.html
        format.csv { send_data Job.export(@jobs), filename: "Jobs-#{Date.today}.csv" }
      end
    end

    def show
    end

    def new
      @job = Job.new
    end

    def edit
    end

    def create
      @job = Job.new(job_params)
      @job.ownerable = current_person

      respond_to do |format|
        if @job.save
          format.html { redirect_to admin_job_path(@job), notice: 'Job was successfully created.' }
          format.json { render :show, status: :created, location: @job }
        else
          format.html { render :new }
          format.json { render json: @job.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @job.update(job_params)
          format.html { redirect_to admin_job_path(@job), notice: 'Job was successfully updated.' }
          format.json { render :show, status: :ok, location: @job }
        else
          format.html { render :edit }
          format.json { render json: @job.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @job.destroy
      respond_to do |format|
        format.html { redirect_to admin_jobs_path, notice: 'Job was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_job
        @job = Job.find(params[:id])
      end

      def job_params
        params[:job][:skill_ids] = params[:job][:skill_ids].map(&:to_i)
        params.require(:job).permit(:title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode, :state, :country, :start_date, :end_date, :latitude, :longitude, :status, :job_category_id, :user_id, skill_ids: [])
      end

      def get_collection
        @job_categories = JobCategory.order(:name).map{|category| [category.name, category.id]}
        @payment_terms  = Job::PAYMENT_TERM
        @payment_types  = Job::PAYMENT_TYPE
      end
  end
end