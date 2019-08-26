class ApplicationPolicy
  attr_reader :user, :record, :role_action, :object

  def initialize(context, record)
    @user        = context.user
    @role_action = context.role_action
    @object      = context.object
    @record      = record
  end

  def index?
    return false unless any_role?
    yield if block_given?
    return eval("#{role_attributes[action]['view']}") rescue false
  end

  def show?
    index?
  end

  def create?
    return false unless any_role?
    yield if block_given?
    return eval("#{role_attributes[action]['add']}") rescue false
  end

  def new?
    create?
  end

  def update?
    return false unless any_role?
    yield if block_given?
    return eval("#{role_attributes[action]['edit']}") rescue false
  end

  def edit?
    update?
  end

  def destroy?
    return false unless any_role?
    yield if block_given?
    return eval("#{role_attributes[action]['delete']}") rescue false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

  def any_role?
    return false unless user_role
    return false unless role_attributes.key?(action)
    return true
  end

  def action
    @action ||= role_action[:action]
  end

  def user_role
    return user.role
  end

  def role_attributes
    new_authorities = {}
    user_role.try(:authorities).each do |key, val|
      new_authorities[key.to_s] = {}

      val.each do |key1, val1|
        new_authorities[key.to_s][key1.to_s] = val1
      end
    end if !user_role.try(:authorities).keys.blank?

    return new_authorities || {}
  end
end
