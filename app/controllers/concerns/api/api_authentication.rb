module Api::ApiAuthentication
  extend ActiveSupport::Concern

  included do
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token
    before_action :check_login_time
  end

  def current_user
    access_token = request.headers['access-token'] || params[:access_token]
    @current_user ||= User.find_by_access_token(access_token)
    return @current_user.present? ? @current_user : nil
  end

  def check_login_time
    render json: { errors: "Invalid access token!" }, status: 401 and return unless current_user
  end

end