class SchoolApply < ApplicationRecord
  belongs_to :user
  belongs_to :menthor
  belongs_to :school_partner
end
