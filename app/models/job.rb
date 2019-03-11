class Job < ApplicationRecord
  include Geocoderable
  include AASM

  serialize :skill_ids, Array

  belongs_to :user
  belongs_to :job_category

  has_many :pictures, as: :pictureable, dependent: :destroy
  accepts_nested_attributes_for :pictures

  has_many :job_requests
  has_many :reviews

  def skills
    skills = Skill.where(id: self.skill_ids)

    return skills
  end

  aasm :column => :status do
    state :pending, initial: true
    state :on_progress
    state :completed

    event :on_progress do
      transitions from: [:pending], to: :on_progress
    end
    event :complete do
      transitions from: [:on_progress], to: :completed
    end
    event :incomplete do
      transitions from: [:completed], to: :on_progress
    end
  end
end
