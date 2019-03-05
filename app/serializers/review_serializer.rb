class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :sender_id, :job_id, :comment, :rate
end
