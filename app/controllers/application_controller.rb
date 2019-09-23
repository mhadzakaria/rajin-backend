include Devise::Controllers::Helpers::ClassMethods

class ApplicationController < ActionController::Base
  include Pundit
  include ErrorsHandlers

  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  skip_before_action :authenticate_user!, only: [:error_404]

  layout :set_layout

  def current_person
    @current_person = current_user || current_mentor
  end

  def error_404
    raise ActionController::RoutingError.new(params[:path])
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: 200 }
      format.js   { render js: "window.location = #{root_path}", alert: "Page not found", status: 404 }
      format.json { render json: { message: exception.message }, status: 404 }
      format.all  { render json: { message: "Page not found"}, status: 400 }
    end
  end

  rescue_from ActionController::UnknownFormat do |exception|
    respond_to do |format|
      format.all  { render json: { message: "Bad request"}, status: 400 }
    end
  end

  rescue_from ActionView::MissingTemplate do |exception|
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: 200 }
      format.json { render json: { message: "Not found" }, status: 404 }
      format.all  { render json: { message: "Bad request"}, status: 400 }
    end
  end

  rescue_from JSON::ParserError do |exception|
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: 200 }
      format.json { render json: { message: "Invalid parameter." }, status: 422 }
      format.all  { render json: { message: "Invalid parameter."}, status: 422 }
    end
  end

  private

    def set_layout
      return 'application' if user_signed_in?
      return 'signedout_layout'
    end

    def pundit_user
      Pundit::CurrentContext.new(current_person, @role_action, @object)
    end

end
