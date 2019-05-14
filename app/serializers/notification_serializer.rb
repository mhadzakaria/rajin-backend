class NotificationSerializer < ApplicationSerializer
  attributes :id, :user_detail, :notifable_type, :notifable_id, :message, :status, :amount, :reduce_coin, :created_at, :updated_at

  def user_detail
    user = object.user
    return user_details(user)
  end
end
