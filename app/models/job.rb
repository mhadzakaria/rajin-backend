class Job < ApplicationRecord
	belongs_to :user
	belongs_to :job_category
	has_many :skills
  has_many :pictures, as: :pictureable
  has_many :job_requests
end
