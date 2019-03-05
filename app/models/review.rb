class Review < ApplicationRecord
  belongs_to :user
  belongs_to :sender, foreign_key: :sender_id, class_name: "User"
  belongs_to :job
end
