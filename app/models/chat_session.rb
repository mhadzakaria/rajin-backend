class ChatSession < ApplicationRecord
  belongs_to :user
  belongs_to :user_job, foreign_key: "user_job_id", class_name: 'User'
  belongs_to :job_request

  enum status: { opened: 0, closed: 1 }

  scope :owner_job, ->(user_id) {where(user_job_id: user_id)}
  scope :normal_user, ->(user_id) {where(user_id: user_id)}

  def job
    self.job_request.job
  end
end
