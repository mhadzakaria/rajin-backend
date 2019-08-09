module Api::V1
  class NotificationsController < Api::BaseApiController
    before_action :set_notification, except: :user_notifications

    def show
      @notification.read
      respond_with @notification, serializer: NotificationSerializer, base_url: request.base_url, status: 200
    end

    def destroy
      @notification.destroy
      render json: @notification, serialize: NotificationSerializer, base_url: request.base_url, status: 204
    end

    def user_notifications
      @notifications = current_user.notifications.showable.order(created_at: :desc)
      render json: @notifications, each_serializer: NotificationSerializer, base_url: request.base_url, status: 200
    end

    private
    def set_notification
      @notification = Notification.find(params[:id])
    end
  end
end