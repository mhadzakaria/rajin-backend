class Order < ApplicationRecord
  belongs_to :user
  belongs_to :orderable, polymorphic: true
end
