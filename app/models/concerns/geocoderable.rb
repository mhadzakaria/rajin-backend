module Geocoderable
  extend ActiveSupport::Concern

  # Make sure included model have these fields for define geocoder latitude and longitude:
  # t.text     :full_address
  # t.string   :city
  # t.string   :postcode
  # t.string   :state
  # t.string   :country
  # t.float    :latitude
  # t.float    :longitude

  included do
    geocoded_by :full_address
    reverse_geocoded_by :latitude, :longitude

    after_validation :geocode, :if => lambda{ |obj| obj.full_address_changed? and obj.full_address.downcase != "world wide" } # auto-fetch coordinates
  end
end