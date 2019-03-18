class JobRequest < ApplicationRecord
	include AASM

  belongs_to :user
  belongs_to :job

  paginates_per 10

  validate :ensure_user_not_same, on: :create
  validates :job_id, uniqueness: { scope: :user_id, message: "Request already applied to this job before." }

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

  def reject_another_job_requests(accept_message = "", reject_message = "")
    self.send_accepted_message(accept_message)

    another_job_requests = job.job_requests.where.not(id: self.id).pending
    another_job_requests.each do |job_request|
      job_request.reject!
      job_request.reload
      job_request.rejected_message(message)
    end
  end

  def send_accepted_message(message)
    # send notification to accepted user job request
    NotificationMailer.job_request_accepted(self.user, message).deliver if self.accepted?
  end

  def rejected_message(message)
    # send notification to rejected user job requests
    NotificationMailer.job_request_rejected(self.user, message).deliver if self.rejected?
  end

  def ensure_user_not_same
    errors.add(:error, "You cannot apply job request to own job post.") if job.user_id.eql?(user_id)
  end
end
