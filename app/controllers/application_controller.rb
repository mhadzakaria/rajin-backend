class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  layout :set_layout

  private

    def set_layout
      return 'application' if user_signed_in?
      return 'signedout_layout'
    end

end
