class SchoolApply < ApplicationRecord
	belongs_to :user
	belongs_to :school_partner
end
