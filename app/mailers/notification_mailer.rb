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
end
