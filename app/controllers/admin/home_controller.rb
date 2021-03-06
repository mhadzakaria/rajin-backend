module Admin
  class HomeController < ApplicationController

    def home
      time_range        = Time.now.beginning_of_month..Time.now.end_of_month
      begin_month       = time_range.first
      end_month         = time_range.last
      @range_per_week    = Array.new

      while begin_month < end_month
        @range_per_week << [begin_month..begin_month.end_of_week]
        begin_month = (begin_month + 1.weeks).beginning_of_week
      end

      @users            = User.all.where(role_id: nil)
      @jobs             = Job.all
      @job_requests     = JobRequest.all
      @orders           = Order.all
      @new_users        = @users.where(created_at: time_range)
      @new_jobs         = @jobs.where(created_at: time_range)
      @new_job_requests = @job_requests.where(created_at: time_range)
      @ten_new_users    = @new_users.sample(8)
      @job_per_week     = @range_per_week.map{ |range| @new_jobs.where(created_at: range) }.map(&:size).reverse.join(',')
      @job_req_per_week = @range_per_week.map{ |range| @new_job_requests.where(created_at: range) }.map(&:size).reverse.join(',')


      # dataset 1 for chart job & job_request
      # dataset 2 for chart overall progress
      @dataset1 = job_datasets(@jobs, @job_requests)
      @dataset2 = overall_datasets(@jobs, @job_requests, @users)
    end

    def job_datasets(jobs, job_requests)
      dataset = {jobs: [], job_requests: []}
      months = Date::MONTHNAMES.last(12)

      job = jobs.group_by { |job| job.created_at.strftime("%B") }
      months.each do |month|
        dataset[:jobs] << (job[month].count rescue 0)
      end

      job_request = job_requests.group_by { |month| month.created_at.strftime("%B") }
      months.each do |month|
        dataset[:job_requests] << (job_request[month].count rescue 0)
      end

      dataset
    end

    def overall_datasets(jobs, job_requests, users)
      dataset = {jobs: [], job_requests: [], users: []}
      months = Date::MONTHNAMES.last(12)

      job = jobs.group_by { |job| job.created_at.strftime("%B") }
      months.each do |month|
        dataset[:jobs] << ([month, job[month].count] rescue [month, 0])
      end

      job_request = job_requests.group_by { |month| month.created_at.strftime("%B") }
      months.each do |month|
        dataset[:job_requests] << ([month, job_request[month].count] rescue [month, 0])
      end

      data_users = users.group_by { |user| user.created_at.strftime("%B") }
      months.each do |month|
        dataset[:users] << ([month, data_users[month].count] rescue [month, 0])
      end

      dataset
    end
  end
end