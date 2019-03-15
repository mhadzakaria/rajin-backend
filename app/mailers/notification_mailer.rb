class NotificationMailer < ApplicationMailer
  # default_from
  # job request notification mailer
	def job_request_accepted(user, message)
    @user    = user
    @message = message
    mail(to: user.email, subject: 'Notification for your job request')
  end

  def job_request_rejected(user, message)
    @user    = user
    @message = message
  	mail(to: user.email, subject: 'Notification for your job request')
  end
end
