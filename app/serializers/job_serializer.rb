class JobSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode, :state, :country, :start_date, :end_date, :latitude, :longitude, :status, :job_category_id, :skills, :pictures, :chat_sessions, :job_owner

  # def skills
  #   if object.skill_ids.present?
   #    skills = object.skill_ids.tr('[]', '').split(',').map(&:to_i)
   #    skills.each do |skill|
   #      Skill.find(skill).name
   #    end
   #  end
  # end

  def skills(data = [])
    skills = object.skills
    skills.each do |skill|
      datum        = {}
      datum[:id]   = skill.id
      datum[:name] = skill.name
      # datum[:skill_logo_url]  = skill.picture.file_url
      # datum[:skill_logo_type] = skill.picture.file_type
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

  def job_owner(data = {})
    user = object.ownerable
    avatar = user.picture

    data[:id]           = user.id
    data[:nickname]     = user.get_nickname
    data[:first_name]   = user.first_name
    data[:last_name]    = user.last_name
    data[:email]        = user.email
    data[:phone_number] = user.phone_number
    data[:full_address] = user.full_address
    data[:city]         = user.city
    data[:postcode]     = user.postcode
    data[:state]        = user.state
    data[:country]      = user.country
    data[:latitude]     = user.latitude
    data[:longitude]    = user.longitude
    data[:avatar_url]       = avatar.try(:file_url).try(:url)
    # data[:company]    = user.company

    return data
  end

end