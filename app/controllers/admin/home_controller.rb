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

      @dataset = job_datasets(@jobs, @job_requests)
    end

    def job_datasets(jobs, job_requests)
      dataset = {jobs: [], job_requests: []}
      month = (Date.today.beginning_of_year..Date.today.end_of_year).map{|p| p.strftime("%B")}.uniq

      job = jobs.group_by { |m| m.created_at.strftime("%B") }
      month.each do |m|
        dataset[:jobs] << (job[m].size rescue 0)
      end

      job_request = job_requests.group_by { |m| m.created_at.strftime("%B") }
      month.each do |m|
        dataset[:job_requests] << (job_request[m].size rescue 0)
      end

      dataset
    end
  end
end