class Skill < ApplicationRecord
  belongs_to :user
  belongs_to :job

  has_one    :picture, as: :pictureable
end
