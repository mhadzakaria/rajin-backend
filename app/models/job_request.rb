class JobRequest < ApplicationRecord
	include AASM

  belongs_to :user
  belongs_to :job

  has_one :chat_session

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

  after_create :create_chat_session
  after_update :update_chat_session

  def reject_another_job_requests(accept_message = "", reject_message = "")
    self.send_accepted_message(accept_message)

    another_job_requests = job.job_requests.where.not(id: self.id).pending
    another_job_requests.each do |job_request|
      job_request.reject!
      job_request.reload
      job_request.rejected_message(reject_message)
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
    errors.add(:error, "You cannot apply job request to own job post.") if job.ownerable_id.eql?(user_id) && job.ownerable_type == "User"
  end

  def create_chat_session
    chat_session = self.build_chat_session
    chat_session.user     = self.user
    chat_session.user_job = self.job.ownerable
    # chat_session.provider_url = create_provider_url #CREATE URL FORM FIREBAS
    chat_session.save
  end

  def create_provider_url
  end

  def update_chat_session
    if self.status.eql?('rejected')
      self.chat_session.update(status: 1)
    end
  end
end
