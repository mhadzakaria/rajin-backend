module Api::V1::Users
  class PasswordsController < Devise::PasswordsController
  	prepend_before_action :require_no_authentication

    def create
    	@user = User.find_by_email(params[:user][:email])
    	if @user.present?
			  @user.send_reset_password_instructions
			  render json: {message: "You will receive an email with instructions on how to reset your password in a few minutes."}, status: 200
			else
			  render json: {message: "Sorry. Your email not found."}, status: 404
			end
	  end

  end
end