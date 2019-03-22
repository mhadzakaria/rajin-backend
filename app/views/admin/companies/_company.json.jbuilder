json.extract! company, :id, :name, :status, :phone_number, :full_address, :city, :postcode, :state, :country, :latitude, :longitude, :created_at, :updated_at
json.url company_url(company, format: :json)
