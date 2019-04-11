module Admin
  class JobRequestsController < ApplicationController
    before_action :set_job_request, only: [:show, :edit, :update, :destroy]

    def index
      # filter collection
      @users        = User.all.map{|user| [user.full_name, user.id]}
      @jobs         = Job.all.map{|job| [job.title, job.id]}
      @statues      = JobRequest.aasm.states.map{|state| [state.name.to_s.humanize, state.name]}

      @q            = JobRequest.ransack(params[:q])
      @job_requests = @q.result.page(params[:page])

      respond_to do |format|
        format.html
        format.csv { send_data JobRequest.export(@job_requests), filename: "Job Requests-#{Date.today}.csv" }
      end
    end

    def show
      @chat_session = @job_request.chat_session
    end

    def new
      @job_request = JobRequest.new
    end

    def edit
    end

    def create
      @job_request = current_user.job_requests.build(job_request_params)

      respond_to do |format|
        if @job_request.save
          format.html { redirect_to admin_job_requests_path, notice: 'Job request was successfully created.' }
          format.json { render :show, status: :created, location: @job_request }
        else
          format.html { render :new }
          format.json { render json: @job_request.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @job_request.update(job_request_params)
          format.html { redirect_to admin_job_requests_path, notice: 'Job request was successfully updated.' }
          format.json { render :show, status: :ok, location: @job_request }
        else
          format.html { render :edit }
          format.json { render json: @job_request.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @job_request.destroy
      respond_to do |format|
        format.html { redirect_to admin_job_requests_path, notice: 'Job request was successfully destroyed.' }
        format.json { head :no_content }
      end
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