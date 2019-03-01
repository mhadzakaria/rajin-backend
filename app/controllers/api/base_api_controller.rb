module Api
  class BaseApiController < ApplicationController
    include ActionController::Serialization
	  include Api::ApiAuthentication
	  include ErrorsHandlers

    before_action :verify_requested_format!

    respond_to :json
  end
end