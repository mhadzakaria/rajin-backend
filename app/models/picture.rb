class Picture < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :pictureable, polymorphic: true
end
