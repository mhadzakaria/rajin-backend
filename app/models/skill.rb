class Skill < ApplicationRecord
  has_one    :picture, as: :pictureable
end
