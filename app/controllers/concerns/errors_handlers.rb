module ErrorsHandlers
  extend ActiveSupport::Concern

  included do
    # Handling error record not found
    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: {message: exception.message}, status: 404
    end

    # Handling argument error
    rescue_from ArgumentError do |exception|
      render json: {message: exception.message}, status: 422
    end

    # Handling no route match
    rescue_from ActionController::RoutingError do |exception|
      render json: {message: "Page not found 404"}, status: 404
    end

    # Handling missing parameters
    rescue_from ActionController::ParameterMissing do |exception|
      render json: {message: exception.message}, status: 422
    end

    # Handling invalid transition AASM state
    rescue_from AASM::InvalidTransition do |exception|
      render json: {message: exception.message}, status: 422
    end

    rescue_from Pundit::NotAuthorizedError, with: :not_authorized_to_access

  end

  def not_authorized_to_access
    user_id = current_person.id
    c_name  = controller_name.gsub("_controller", "")

    flash[:alert] = "Your user ID: #{user_id} : You are not allow to access any function in #{c_name.humanize} management."
    respond_to do |format|
      format.html { redirect_to(request.referrer || root_path) }
      format.json { render json: {message: "#{flash[:alert]}"} }
    end
  end
end