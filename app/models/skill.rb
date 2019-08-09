class Skill < ApplicationRecord
  has_one    :picture, as: :pictureable, dependent: :destroy
  has_many :level_skills, dependent: :destroy
  has_many :users, through: :level_skills

  paginates_per 10
end
