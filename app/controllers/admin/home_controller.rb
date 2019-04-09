module Admin
  class HomeController < ApplicationController

    def home
      @users        = User.all
      @jobs         = Job.all
      @job_requests = JobRequest.all
      @orders       = Order.all
    end
  end
end