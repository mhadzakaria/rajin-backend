module Api::V1
  class ChatSessionsController < Api::BaseApiController
    before_action :set_job_request, only: [:create]

    def index
      @chat_sessions = ChatSession.normal_user(current_user.id).or(ChatSession.owner_job(current_user.id))
      respond_with @chat_sessions, each_serializer: ChatSessionSerializer, base_url: request.base_url, status: 200
    end

    def create
      @chat_session = @job_request.chat_session

      if @chat_session.blank?
        @chat_session = ChatSession.new(chat_session_params)
        @chat_session.build_firebase_key(params[:job_id])
        @chat_session.save
      end

      if @chat_session.errors.blank?
        render json: @chat_session, serialize: ChatSessionSerializer, base_url: request.base_url, status: 200
      else
        render json: { error: @chat_session.errors.full_messages }, status: 422
      end
    end

    private

    def set_job_request
      @job_request = JobRequest.find(chat_session_params[:job_request_id])
    end

    def chat_session_params
      params.require(:chat_session).permit(:id, :user_id, :user_job_id, :job_request_id, :status, :provider_url)
    end
  end
end