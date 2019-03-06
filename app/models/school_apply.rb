class SchoolApply < ApplicationRecord
  belongs_to :user
  belongs_to :mentor
  belongs_to :school_partner
end
