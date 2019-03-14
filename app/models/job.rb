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

  class << self
    def filter(user, skill_ids, amount, distance, verified)
      filter_skill = []
      filter_amount = []
      filter_distance = []
      if skill_ids.present?
        skill_ids.each do |skill|
          Job.all.each do |job|
            if job.skill_ids.include?(skill)
              filter_skill << job
            end
          end
        end
      end
      if amount.present?
        filter_amount = Job.all.where(amount: amount)
      end
      if distance.present?
        filter_distance = Geocoderable.distance_filter(user, distance)
      end
      return (filter_amount + filter_distance + filter_skill).uniq
    end
  end

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
