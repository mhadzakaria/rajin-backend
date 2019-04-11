class SchoolPartner < ApplicationRecord
  include Geocoderable

  has_one  :picture, as: :pictureable
  has_many :school_applies

  paginates_per 10

  def self.export(school_partners)
    attributes = ["name", "phone_number", "full_address", "city", "postcode", "state", "country", "latitude", "longitude", "created_at", "updated_at"]
    to_csv(school_partners, attributes)
  end
end
