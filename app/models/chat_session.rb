class ChatSession < ApplicationRecord
  belongs_to :user
  belongs_to :user_job, foreign_key: "user_job_id", class_name: 'User'
  belongs_to :job_request

  enum status: { opened: 0, closed: 1 }

  default_scope { order(created_at: :desc) }

  scope :owner_job,   ->(user_id) {where(user_job_id: user_id)}
  scope :normal_user, ->(user_id) {where(user_id: user_id)}
  scope :my_chat,     ->(user_id) {where("user_id = ? or user_job_id = ?", user_id, user_id)}
  scope :open_chat,   -> { where(status: 'opened') }
  scope :close_chat,  -> { where(status: 'closed') }

  def job
    self.job_request.job
  end

  def build_firebase_key(job_id)
    random_key   = SecureRandom.hex(10)
    firebase_key = "job_request-#{job_request_id}-#{job_id}-#{random_key}"

    self.provider_url = firebase_key
  end
end
