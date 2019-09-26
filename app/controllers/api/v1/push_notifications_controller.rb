module Api::V1
  class PushNotificationController < Api::BaseApiController

    def update_registration_id
      if current_user
        fcm_registration_ids
        fcm_registration_ids = @current_user.fcm_registration_ids
        if !fcm_registration_ids.include?(params[:fcm_id])
          fcm_registration_ids << params[:fcm_id]
          @current_user.update(fcm_registration_ids: fcm_registration_ids)
          render json: { message: 'FCM updated'}
        end
      else
        render json: { error: 'User doesnt exist' }, status: 422
      end
    end

    def create_for_chat
      chat_session = ChatSession.find(params[:chat_id])
      user_ids = [chat_session.user_id, chat_session.user_job_id]
      fcm_registration_ids = User.where(id: user_ids).pluck(:fcm_registration_ids).flatten

      fcm_client = FCM.new(ENV['FCM_SERVER_KEY'])
      message = params[:message]
      options = {priority: 'high' ,data: {message: message },notification: { body: message, sound: 'default' }}

      response =  fcm_client.send(fcm_registration_ids, options)
      if response[:response] == 'success'
        render json: { message: 'submitted' }, status: 200
      else
        render json: { message: 'error' }, status: 500
      end
    end
  end
end