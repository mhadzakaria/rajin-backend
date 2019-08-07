module Api::V1
  class UsersController < Api::BaseApiController
  	before_action :set_user

  	def show
      render json: @user, serializer: UserSerializer, base_url: request.base_url, current_user: false, status: 200 and return
  	end

  	private

  	def set_user
  		@user = User.find(params[:id])
  	end
  end
end