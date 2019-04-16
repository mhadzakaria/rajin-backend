module Pundit
  module Authorization
    extend ActiveSupport::Concern

      included do
        class_attribute :skipped_authorizations

        # you can customize skipped authorization as needed,
        # just add self.skipped_authorizations = [your_action] on controller that included this module
        # for example:
        # self.skipped_authorizations = [:index, :show, :new, :edit, :create, :update, :delete]
        self.skipped_authorizations = []

        before_action :authorize_action
      end

      def authorize_action
        unless self.skipped_authorizations.map(&:to_sym).include?(action_name.to_sym)
          set_role_action
          get_object
          authorize model_name, action_auth
        end
      end

      def set_role_action
        @role_action ||= {action: "#{controller_name}_auth"}
        return @role_action
      end

      def action_auth
        case action_name.to_sym
        when :index, :show
          return :show?
        when :new
          return :new?
        when :edit
          return :edit?
        when :create
          return :create?
        when :update
          return :update?
        when :destroy
          return :destroy?
        end
      end

      def model_name
        return controller_name.singularize.camelize.constantize
      end

      def get_object
        @object ||= instance_variable_get("@#{controller_name.singularize}")

        return @object
      end
  end
end