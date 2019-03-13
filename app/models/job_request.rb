class JobRequest < ApplicationRecord
	include AASM

  belongs_to :user
  belongs_to :job

  validate :check_user, :on => :create

  aasm :column => :status do
    state :pending, initial: true
    state :accepted
    state :rejected

    event :accept do
      transitions from: [:pending], to: :accepted
    end
    event :reject do
      transitions from: [:pending], to: :rejected
    end
  end

  def check_user
    job = Job.find(job_id)
    if job.user_id == user_id
      errors.add(:job_request, "cannot be applied")
    end
  end
end
