class MentorSerializer < ApplicationSerializer
  attributes :id, :nickname, :first_name, :last_name. :email, :phone_number, :date_of_birth, :gender, :full_address, :city, :postcode, :state, :country, :latitude, :longitude, :position, :user_type, :access_token, :uuid, :password, :skills, :picture

  def password
    object.password || "Password not displayed"
  end

  def skills(data = [])
    skills = object.skills
    if skills.present?
      skills.each do |skill|
        datum        = {}
        datum[:id]   = skill.id
        datum[:name] = skill.name
        datum[:skill_logo_url]  = skill.picture.file_url
        datum[:skill_logo_type] = skill.picture.file_type
        data << datum
      end
    end

    return data
  end

  def picture(data = [])
    if object.picture.present?
      datum = {}
      datum[:id]               = object.picture.id
      datum[:user_id]          = object.picture.user_id
      datum[:pictureable_id]   = object.picture.pictureable_id
      datum[:pictureable_type] = object.picture.pictureable_type
      datum[:file_type]        = object.picture.file_type
      datum[:file_url]         = object.picture.file_url
      data << datum
    end

    return data
  end

end