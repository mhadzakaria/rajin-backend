include Devise::Controllers::Helpers::ClassMethods

class ApplicationController < ActionController::Base
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

  private

    def set_layout
      return 'application' if user_signed_in?
      return 'signedout_layout'
    end

end
