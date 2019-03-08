class MentorSerializer < ActiveModel::Serializer
  attributes :id, :nickname, :first_name, :last_name, :phone_number, :date_of_birth, :gender, :full_address, :city, :postcode, :state, :country, :latitude, :longitude, :position, :user_type, :access_token, :uuid, :password, :skills, :picture

  def password
    object.password || "Password not displayed"
  end

  def skills(data = [])
    if object.skills.present?
      object.skills.each do |skill|
        datum = {}
        datum[:id] = skill.id
        datum[:name] = skill.name
        # datum[:skill_logo_url]  = skill.picture.file_url
        # datum[:skill_logo_type] = skill.picture.file_type
        data << datum
      end
    end

    return data
  end

  def picture(data = [])
    if object.picture.present?
      datum = {}
      datum[:pictureable_id] = object.picture.pictureable_id
      datum[:file_url] = object.picture.file_url
      data << datum
    end

    return data
  end

end