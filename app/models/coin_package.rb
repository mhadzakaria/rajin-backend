class CoinPackage < ApplicationRecord
  has_many :orders, as: :orderable

  def self.export(users)
    attributes = ["coin", "amount", "created_at", "updated_at"]
    to_csv(users, attributes)
  end
end
