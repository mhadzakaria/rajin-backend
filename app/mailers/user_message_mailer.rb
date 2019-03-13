class UserMessageMailer < ApplicationMailer
	def accept(user_accepted, user_message)
    @user_message = user_message
    mail(to: user_accepted, subject: 'Notification for your job request')
  end

  def reject(user_rejected, user_message)
  	@user_message = user_message
  	mail(to: user_rejected, subject: 'Notification for your job request')
  end
end
