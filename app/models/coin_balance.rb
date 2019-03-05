class CoinBalance < ApplicationRecord
  belongs_to :user
  belongs_to :coinable, polymorphic: true
end
