class Review < ApplicationRecord
  belongs_to :user
  belongs_to :sender, foreign_key: :sender_id, class_name: "User"
  belongs_to :job

  validate :check_status, :on => :create

  def check_status
  	job = Job.find(job_id)
  	if job.status == "pending" || job.status == "on_progress"
  		errors.add(:job, "status must be complete to make a review")
  	end
	end
end
