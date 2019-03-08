class UserSerializer < ActiveModel::Serializer
  attributes :id, :nickname, :first_name, :last_name, :phone_number, :date_of_birth, :gender, :full_address, :city, :postcode, :state, :country, :latitude, :longitude, :user_type, :access_token, :uuid, :password, :config, :skills

  def password
    object.password || "Password not displayed"
  end

  def config(data = {})
    configuration        = object.config
    data[:id]            = configuration.id
    data[:email_notif]   = configuration.email_notif
    data[:receive_notif] = configuration.receive_notif

    return data
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

end