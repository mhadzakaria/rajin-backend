class Job < ApplicationRecord
  include Geocoderable
  serialize :skill_ids, Array

  belongs_to :user
  belongs_to :job_category

  has_many :pictures, as: :pictureable
  has_many :job_requests
  has_many :reviews

  def skills
  	skills = []
  	skill_ids.each do |skill|
      skill = Skill.find(skill)
      skills << skill if skill.present?
    end

  	return skills
  end
end
