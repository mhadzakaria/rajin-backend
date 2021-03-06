class JobSerializer < ApplicationSerializer
  attributes :id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode, :state, :country, :start_date, :duration, :duration_type, :latitude, :longitude, :status, :is_promoted, :job_category, :skills, :pictures, :chat_sessions, :job_owner_detail,

  def skills(data = [])
    skills = object.skills
    skills.each do |skill|
      datum           = {}
      datum[:id]      = skill.id
      datum[:name]    = skill.name
      datum[:picture] = picture_details(skill.picture.try(:file_url))

      data << datum
    end
    
    return data
  end

  def pictures(data = [])
    object.pictures.each do |picture|
      next if picture.file_url.blank?

      datum = {}
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

  def chat_sessions(chat = nil)
    if !current_user.eql?(object.ownerable)
      chat = object.chat_sessions.open_chat.find_by(user: current_user)
    end

    chat
  end

end