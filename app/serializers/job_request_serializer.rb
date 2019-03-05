class JobRequestSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :job_id, :status
end
