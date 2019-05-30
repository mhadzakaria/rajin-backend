module Api::V1
  class ChatSessionsController < Api::BaseApiController

  	def index
  	  @chat_sessions = ChatSession.normal_user(current_user.id).or(ChatSession.owner_job(current_user.id))
  	  respond_with @chat_sessions, each_serializer: ChatSessionSerializer, status: 200
  	end
  end
end