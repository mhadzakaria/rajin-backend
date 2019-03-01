class Job < ApplicationRecord
	belongs_to :company
	belongs_to :job_category
end
