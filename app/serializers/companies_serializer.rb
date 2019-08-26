class CompaniesSerializer < ApplicationSerializer
  attributes  :id, :name, :status, :phone_number, :full_address, :city, :postcode, :state, :country, :latitude, :longitude, :jobs_count, :image

  def jobs_count
    object.jobs.pending.size
  end

  def image(data = nil)
    picture = object.picture
    if picture.try(:file_url).present?
      data = Hash.new

      data[:file_type] = picture.file_type
      data[:file_url]  = picture.file_url
    end

    data
  end
end