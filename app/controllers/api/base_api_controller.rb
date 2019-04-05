module Api
  class BaseApiController < ApplicationController
    include ActionController::Serialization
    include Api::ApiAuthentication
    include ErrorsHandlers

    before_action :verify_requested_format!

    skip_before_action :check_login_time, only: [:error_404]

    respond_to :json
  end
end