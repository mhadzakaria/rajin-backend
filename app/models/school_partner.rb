class SchoolPartner < ApplicationRecord
  include Geocoderable

  has_one  :picture, as: :pictureable
  has_many :school_applies

  paginates_per 10
end
