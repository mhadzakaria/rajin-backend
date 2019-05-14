class SchoolPartnerSerializer < ApplicationSerializer
  attributes :id, :name, :phone_number, :full_address, :city, :postcode, :state, :country, :latitude, :longitude
end
