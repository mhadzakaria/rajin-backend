class Skill < ApplicationRecord
  has_one    :picture, as: :pictureable, dependent: :destroy

  paginates_per 10
end
