class JobSerializer < ApplicationSerializer
  attributes :id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode, :state, :country, :start_date, :end_date, :latitude, :longitude, :status, :job_category_id, :skills, :pictures, :chat_sessions, :job_owner_detail

  def skills(data = [])
    skills = object.skills
    skills.each do |skill|
      datum        = {}
      datum[:id]   = skill.id
      datum[:name] = skill.name
      data << datum
    end
    
    return data
  end

  def pictures(data = [])
    object.pictures.each do |picture|
      datum = {}
      datum[:id]               = picture.id
      datum[:user_id]          = picture.user_id
      datum[:pictureable_id]   = picture.pictureable_id
      datum[:pictureable_type] = picture.pictureable_type
      datum[:file_type]        = picture.file_type
      datum[:file_url]         = picture.file_url

      data << datum
    end

    return data
  end

  def job_owner_detail(data = {})
    owner = object.ownerable

    return user_details(owner)
  end

end