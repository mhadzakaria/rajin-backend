class JobSerializer < ApplicationSerializer
  attributes :id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode, :state, :country, :start_date, :duration, :duration_type, :latitude, :longitude, :status, :is_promoted, :job_category, :skills, :pictures, :chat_sessions, :job_owner_detail,

  def skills(data = [])
    skills = object.skills
    skills.each do |skill|
      datum        = {}
      datum[:id]   = skill.id
      datum[:name] = skill.name

      if skill.picture.present? && skill.picture.file_url.present?
        datum[:id]               = skill.picture.id
        datum[:user_id]          = skill.picture.user_id
        datum[:pictureable_id]   = skill.picture.pictureable_id
        datum[:pictureable_type] = skill.picture.pictureable_type
        datum[:file_type]        = skill.picture.file_type
        datum[:file_url]         = picture_details(skill.picture.file_url)
      end

      data << datum
    end
    
    return data
  end

  def pictures(data = [])
    object.pictures.each do |picture|
      next if picture.file_url.blank?

      datum = {}
      datum[:id]               = picture.id
      datum[:user_id]          = picture.user_id
      datum[:pictureable_id]   = picture.pictureable_id
      datum[:pictureable_type] = picture.pictureable_type
      datum[:file_type]        = picture.file_type
      datum[:file_url]         = picture_details(picture.file_url)

      data << datum
    end

    return data
  end

  def job_owner_detail(data = {})
    owner = object.ownerable

    return user_details(owner)
  end

  def chat_sessions
    object.chat_sessions.open_chat
  end

end