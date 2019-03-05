class SkillSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :job_id, :name
end
