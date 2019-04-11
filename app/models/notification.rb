class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifable, polymorphic: true

  validates_presence_of :message, allow_blank: false

  def send_email_notification
    NotificationMailer.send_notification(self).deliver
  end

  def read
    self.update(status: 'read')
  end
end
