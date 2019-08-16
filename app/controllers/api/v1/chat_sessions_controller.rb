module Api::V1
  class ChatSessionsController < Api::BaseApiController
    before_action :set_job_request, only: [:create]
    before_action :set_chat_session, only: [:send_chat]

    def index
      @chat_sessions = ChatSession.normal_user(current_user.id).or(ChatSession.owner_job(current_user.id)).open_chat
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

    def show
      @chat_session = ChatSession.find(params[:id])
      render json: @chat_session, serialize: ChatSessionSerializer, base_url: request.base_url, status: 200
    end

    def pending
      my_chat = ChatSession.my_chat(current_user).open_chat
      @chat_sessions = my_chat.select { |ch| ch.job_request.try(:status).eql?('pending') }
      respond_with @chat_sessions, each_serializer: ChatSessionSerializer, base_url: request.base_url, status: 200
    end

    def confirmed
      my_chat = ChatSession.my_chat(current_user).open_chat
      @chat_sessions = my_chat.select { |ch| ch.job_request.try(:status).eql?('accepted') }
      respond_with @chat_sessions, each_serializer: ChatSessionSerializer, base_url: request.base_url, status: 200
    end

    def send_chat
      chat = @chat_session.store_chat(params, current_user)

      render json: chat[:data], status: chat[:status]
    end

    private

    def set_chat_session
      @chat_session = ChatSession.find(params[:id])
    end

    def set_job_request
      @job_request = JobRequest.find(chat_session_params[:job_request_id])
    end

    def chat_session_params
      params.require(:chat_session).permit(:id, :user_id, :user_job_id, :job_request_id, :status, :provider_url)
    end
  end
end