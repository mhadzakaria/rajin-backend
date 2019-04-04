class CoinPackage < ApplicationRecord
  has_many :orders, as: :orderable
end
