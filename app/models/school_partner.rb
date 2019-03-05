class SchoolPartner < ApplicationRecord
  include Geocoderable

  has_one  :picture, as: :pictureable
  has_many :school_applies
end
