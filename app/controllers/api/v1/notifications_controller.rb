module Api::V1
  class NotificationsController < Api::BaseApiController
    before_action :set_notification, except: :user_notifications

    def show
      @notification.read
      respond_with @notification, serializer: NotificationSerializer, status: 200
    end

    def destroy
      @notification.destroy
      render json: @notification, serialize: NotificationSerializer, status: 204
    end

    def user_notifications
      @notifications = current_user.notifications
      render json: @notifications, each_serializer: NotificationSerializer, status: 200
    end

    private
    def set_notification
      @notification = Notification.find(params[:id])
    end
  end
end