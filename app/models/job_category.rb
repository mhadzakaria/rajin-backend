class JobCategory < ApplicationRecord
  has_many :jobs

  paginates_per 10
end
