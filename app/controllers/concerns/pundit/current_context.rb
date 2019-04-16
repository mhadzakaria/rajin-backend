module Pundit
  class CurrentContext
    attr_reader :user, :role_action, :object

    def initialize(user, role_action={}, object=nil)
      @user        = user
      @role_action = role_action
      @object      = object
    end
  end
end