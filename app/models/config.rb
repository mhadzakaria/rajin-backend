class Config < ApplicationRecord
  # if mentor can login and allowed to change config, the relation need to updated to polymorphic, so the relation can be used by user and mentor model.
  belongs_to :user
end
