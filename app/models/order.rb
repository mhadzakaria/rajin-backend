class Order < ApplicationRecord
  include Notifiable

  belongs_to :user
  belongs_to :orderable, polymorphic: true
end
