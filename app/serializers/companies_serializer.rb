class CompaniesSerializer < ApplicationSerializer
  attributes  :id, :name, :status, :phone_number, :full_address, :city, :postcode, :state, :country, :latitude, :longitude
end