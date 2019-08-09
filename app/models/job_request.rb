class JobRequest < ApplicationRecord
  include AASM
  include Notifiable

  belongs_to :user
  belongs_to :job

  has_one :chat_session

  paginates_per 10

  validate :ensure_user_not_same, on: :create
  validates :job_id, uniqueness: { scope: :user_id, message: "Request already applied to this job before." }
  validates :job_id, uniqueness: { message: "Job already have worker." }, if: :accepted_job_request

  scope :pending,      -> { where(status: "pending") }
  scope :rejected,     -> { where(status: "rejected") }
  scope :not_rejected, -> { where.not(status: "rejected") }
  scope :accepted,     -> { where(status: "accepted") }


  aasm :column => :status do
    state :pending, initial: true
    state :accepted
    state :rejected

    event :accept, after: [:hide_another_notif, :job_on_progress] do
      transitions from: [:pending], to: :accepted
    end
    event :reject do
      transitions from: [:pending], to: :rejected
    end
  end

  after_create :send_notification
  # after_create :create_chat_session, :send_notification
  after_update :update_chat_session

  def hide_another_notif
    job_job_requests = self.job.job_requests

    # hide another job_requests notifications
    notifications = job_job_requests.map{|jr| jr.notifications}.flatten
    notifications.each do |notif|
      if !notif.notifable.eql?(self)
        notif.update(is_show: false)
      end
    end

    # hide another job_requests chat_sessions
    job_requests = job_job_requests.map{|jr| jr.chat_session }.compact
    job_requests.each do |chat|
      if !chat.job_request.eql?(self)
        chat.update(status: 1)
      end
    end
  end

  def job_on_progress
    job.on_progress!
  end

  def accepted_job_request
    job.job_requests.where(status: 'accepted').present?
  end

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
    self.create_notification(self.user, message) if self.accepted?
  end

  def rejected_message(message)
    # send notification to rejected user job requests
    self.create_notification(self.user, message) if self.rejected?
  end

  def ensure_user_not_same
    errors.add(:error, "You cannot apply job request to own job post.") if job.ownerable_id.eql?(user_id) && job.ownerable_type == "User"
  end

  def create_chat_session
    chat_session = self.build_chat_session
    chat_session.user     = self.user
    chat_session.user_job = self.job.ownerable
    chat_session.provider_url = "job_request-#{self.id}-#{self.job.id}"
    chat_session.save
  end

  def create_provider_url
  end

  def update_chat_session
    if self.status.eql?('rejected') && self.chat_session
      self.chat_session.update(status: 1)
    end
  end

  def send_notification
    job_owner = job.ownerable
    message   = "#{user.full_name} has been applied to your job offer '#{job.title}'."
    self.create_notification(job_owner, message)
  end

  def self.export(job_requests)
    attributes = ["user_csv", "job_csv", "status", "created_at", "updated_at"]
    to_csv(job_requests, attributes)
  end

  def user_csv
    self.user.email
  end

  def job_csv
    self.job.title
  end
end
