class JobSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode, :state, :country, :start_date, :end_date, :latitude, :longitude, :status, :job_category_id, :company_id
end