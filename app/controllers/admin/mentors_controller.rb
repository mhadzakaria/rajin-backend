module Admin
  class MentorsController < ApplicationController

    include Pundit::Authorization

    def index
      @q = Mentor.ransack(params[:q])
      @mentors = @q.result.page(params[:page])
    end

    def show
      @mentor = Mentor.find(params[:id])
    end
  end
end