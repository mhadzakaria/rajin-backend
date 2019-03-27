module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifable, dependent: :destroy
  end

  def create_notification(user, message = "")
    data  = {user_id: user.try(:id), status: 'sent', message: message}
    notif = self.notifications.build(data)
    notif.send_email_notification if notif.save

    return notif
  end

end