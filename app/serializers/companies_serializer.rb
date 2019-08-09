class CompaniesSerializer < ApplicationSerializer
  attributes  :id, :name, :status, :phone_number, :full_address, :city, :postcode, :state, :country, :latitude, :longitude, :jobs_count

  def jobs_count
    object.jobs.pending.size
  end
end