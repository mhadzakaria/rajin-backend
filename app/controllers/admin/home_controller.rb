module Admin
  class HomeController < ApplicationController

    def home
      time_range        = Time.now.beginning_of_month..Time.now.end_of_month

      @users            = User.all
      @jobs             = Job.all
      @job_requests     = JobRequest.all
      @orders           = Order.all
      @new_users        = @users.where(created_at: time_range)
      @new_jobs         = @jobs.where(created_at: time_range)
      @new_job_requests = @job_requests.where(created_at: time_range)
    end
  end
end