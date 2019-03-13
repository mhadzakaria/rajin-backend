module Api::V1
  class UserMessagesController < Api::BaseApiController
    before_action :set_user_message, only: [:show, :destroy, :update]
    before_action :set_user, only: [:create]

    def index
      @user_messages = UserMessage.all
      respond_with @user_messages, each_serializer: UserMessageSerializer, status: 200
    end

    def show
      respond_with @user_message, serializer: UserMessageSerializer, status: 200
    end

    def create
      @user_message = UserMessage.new(user_message_params)
      if @user_message.save
        UserMessageMailer.accept(@user_accepted, @user_message).deliver
        @user_rejected.each do |user_rejected|
          UserMessageMailer.reject(user_rejected, @user_message).deliver
        end
        render json: @user_message, serialize: UserMessageSerializer, status: 200
      else
        render json: { error: @user_message.errors.full_messages }, status: 422
      end
    end

    def update
      if @user_message.update(user_message_params)
        render json: @user_message, serialize: UserMessageSerializer, status: 200
      else
        render json: { error: @user_message.errors.full_messages }, status: 422
      end
    end

    def destroy
      @user_message.destroy
      render json: @user_message, serialize: UserMessageSerializer, status: 204
    end

    private

    def set_user_message
      @user_message = UserMessage.find(params[:id])
    end

    def set_user
      job_req = JobRequest.find(params[:user_message][:job_request_id])
      @user_accepted = JobRequest.find(params[:user_message][:job_request_id]).user.email
      @user_rejected = []
      JobRequest.where(job_id: job_req.job_id).each do |job_request|
        if job_request.status != "accepted"
          @user_rejected << (job_request.user.email)
        end
      end
    end

    def user_message_params
      params.require(:user_message).permit(:job_request_id, :message_for_accepted_user, :message_for_rejected_user)
    end
  end
end