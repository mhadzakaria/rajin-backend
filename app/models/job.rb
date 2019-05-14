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
    def filter(user, search)
      filter                = {}
      filtered_skill_ids    = []
      filtered_distance_ids = []

      jobs = Job.all

      # collect job id by skill ids
      search[:skill_ids].each do |skill|
        jobs.each do |job|
          if job.skill_ids.include?(skill)
            filtered_skill_ids << job.id
          end
        end
      end unless search[:skill_ids].blank?

      # collect job id by distance from user location
      if filter[:distance].present?
        filtered_distance_ids = jobs.near(user.coordinates, filter[:distance], units: :km).map(&:id)
      end

      # filter job by skill ids and distance
      filtered_ids               = filtered_skill_ids + filtered_distance_ids

      # build ransack filter query (amount and specific location data)
      filter[:amount_eq]         = search[:amount] if search[:amount].present?
      filter[:full_address_cont] = search[:full_address] if search[:full_address].present?
      filter[:city_cont]         = search[:city] if search[:city].present?
      filter[:state_cont]        = search[:state] if search[:state].present?
      filter[:country_cont]      = search[:country] if search[:country].present?
      filter[:postcode_eq]       = search[:postcode] if search[:postcode].present?

      # filter job with ransack
      query = jobs.ransack(filter)
      # filter job to find match skill and distance location
      jobs  = query.result.where(id: filtered_ids)

      return jobs
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
