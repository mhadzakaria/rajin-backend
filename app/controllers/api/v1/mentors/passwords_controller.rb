module Api::V1::Mentors

  class PasswordsController < Devise::PasswordsController
    prepend_before_action :require_no_authentication

    def create
      @mentor = Mentor.find_by_email(params[:mentor][:email])
      if @mentor.present?
        @mentor.send_reset_password_instructions
        render json: {message: "You will receive an email with instructions on how to reset your password in a few minutes."}, status: 200
      else
        render json: {message: "Sorry. Your email not found."}, status: 404
      end
    end
  end
end
