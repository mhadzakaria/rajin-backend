module Api::ApiAuthentication
  extend ActiveSupport::Concern

  included do
    # devise_group :person, contains: [:user, :mentor]

    class_attribute :login_user_type

    # Login_user_type, can be changed to :user or :mentor on each controller (example, check on user and mentor devise controllers)
    # Condition details:
    # either => logged in user type is one of mentor or user (current_user or current_mentor) [current_person]
    # user   => logged in user type is user   (current_user)
    # mentor => logged in user type is mentor (current_mentor)
    self.login_user_type = :either

    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token
    before_action :check_login_time
  end

  def current_user
    access_token = request.headers['access-token'] || params[:access_token]
    @current_user ||= User.find_by_access_token(access_token)
    return @current_user.present? ? @current_user : nil
  end

  def current_mentor
    access_token = request.headers['access-token'] || params[:access_token]
    @current_mentor ||= Mentor.find_by_access_token(access_token)
    return @current_mentor.present? ? @current_mentor : nil
  end

  def current_person
    @current_person = current_user || current_mentor
  end

  def check_login_time
    invalid   = current_person.blank? && login_user_type.eql?(:either)
    invalid ||= current_user.blank? && login_user_type.eql?(:user)
    invalid ||= current_mentor.blank? && login_user_type.eql?(:mentor)

    render json: { errors: "Invalid access token!" }, status: 401 and return if invalid
  end

end