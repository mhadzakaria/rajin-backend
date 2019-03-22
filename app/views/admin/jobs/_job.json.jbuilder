json.extract! job, :id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode, :state, :country, :start_date, :end_date, :latitude, :longitude, :status, :job_category_id, :user_id, :skill_ids, :created_at, :updated_at
json.url job_url(job, format: :json)
