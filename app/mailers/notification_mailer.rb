class NotificationMailer < ApplicationMailer
  # default_from
  # job request notification mailer
  def send_notification(notification)
    @message   = notification.message
    @user      = notification.user
    @notifable = notification.notifable
    @subject   = "#{@notifable.class.name.underscore.titleize} Notification"

    mail(to: @user.email, subject: @subject)
  end

  # mailer for model user notification
  def send_user_current_password(user, current_password)
    @user             = user
    @current_password = current_password
    @subject   = "Your account has been registered"

    mail(to: @user.email, subject: @subject)
  end

end
