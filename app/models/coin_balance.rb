class CoinBalance < ApplicationRecord
  include Notifiable

  belongs_to :user
  belongs_to :coinable, polymorphic: true
end
