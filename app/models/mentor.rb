class Mentor < ApplicationRecord
  include Geocoderable
  serialize :skill_ids, Array

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # belongs_to :company, optional: true

  has_many  :school_applies

  before_create :generate_access_token

  def generate_access_token
    self.access_token = SecureRandom.hex(16)
  end

  def skills
    skills = []
    if skill_ids.present?
      skill_ids.each do |skill|
        skill = Skill.find(skill)
        skills << skill if skill.present?
      end
    end

    return skills
  end
end