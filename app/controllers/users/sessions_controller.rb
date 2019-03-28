class Users::SessionsController < Devise::SessionsController
  def show
    @user = current_user
  end

  protected
    def after_sign_in_path_for(resource)
      if resource.present? && (resource.role.try(:role_code).eql?('admin') || resource.role.try(:role_code).eql?('super_admin'))
        super
      else
        (Devise.sign_out_all_scopes ? sign_out : sign_out(resource))
        flash.clear
        flash[:error] = 'You not allowed to access this page. Please contact our support.'
        root_path
      end
    end

end
