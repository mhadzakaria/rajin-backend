class Job < ApplicationRecord
  PAYMENT_TERM = ['Cash', 'Installment']
  PAYMENT_TYPE = ['One-off', 'Per Hours', 'Per Week', 'Others']

  include AASM
  include Geocoderable
  include Notifiable

  serialize :skill_ids, Array

  belongs_to :ownerable, polymorphic: true
  belongs_to :job_category

  has_many :pictures, as: :pictureable, dependent: :destroy
  accepts_nested_attributes_for :pictures

  has_many :job_requests
  has_many :reviews
  has_many :chat_sessions, through: :job_requests

  paginates_per 10

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

  ransacker :owner_name, formatter: proc { |value| 
    job_ids = Job.where(
      ownerable_id: User.select('users.id as ownerable_id').where('lower(first_name) LIKE ?', "%#{value.downcase}%"),
      ownerable_type: 'User'
    ).pluck(:id) + Job.where(
      ownerable_id: Mentor.select('mentors.id as ownerable_id').where('lower(first_name) LIKE ?', "%#{value.downcase}%"),
      ownerable_type: 'Mentor'
    ).pluck(:id)

    job_ids.presence

    } do |parent|
      parent.table[:id]
  end

  # ransacker :skill_ids do
  #   Arel.sql("array_to_integer(skill_ids, ',')")
  # end

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

  def self.export(jobs)
    attributes = ["title", "description", "payment_term", "amount", "payment_type", "full_address", "city", "postcode", "state", "country", "start_date", "end_date", "latitude", "longitude", "status", "get_category", "owner", "skill", "created_at", "updated_at"]
    to_csv(jobs, attributes)
  end

  def owner
    self.ownerable.email
  end

  def skill
    self.skills.map(&:name).to_sentence
  end

  def get_category
    self.job_category.name
  end

end
