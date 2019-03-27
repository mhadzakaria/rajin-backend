class SubscriptionPackage < ApplicationRecord
  include Notifiable

  belongs_to :user
end
