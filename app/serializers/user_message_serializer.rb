class UserMessageSerializer < ActiveModel::Serializer
  attributes :id, :job_request_id, :message_for_accepted_user, :message_for_rejected_user
end
