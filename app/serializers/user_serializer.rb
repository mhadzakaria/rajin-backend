class UserSerializer < ActiveModel::Serializer
  attributes :id, :nickname, :first_name, :last_name, :phone_number, :date_of_birth, :gender, :full_address, :city, :postcode, :state, :country, :latitude, :longitude, :user_type, :access_token, :uuid, :password, :config, :skills, :avatar, :company_detail, :coin_balance, :notifications

  def password
    object.password || "Password not displayed"
  end

  def config(data = {})
    begin
      configuration        = object.config
      data[:id]            = configuration.id
      data[:email_notif]   = configuration.email_notif
      data[:receive_notif] = configuration.receive_notif
    rescue Exception => e
      data
    end

    return data
  end

  def skills(data = [])
    skills = object.skills

    skills.each do |skill|
      picture                = skill.picture
      datum                  = {}

      datum[:id]             = skill.id
      datum[:name]           = skill.name
      datum[:logo_url]       = picture.try(:file_url).try(:url)
      datum[:logo_file_type] = picture.try(:file_type)
      data << datum
    end

    return data
  end

  def avatar(data = {})
    picture = object.picture

    if picture.present?
      data[:id]               = picture.id
      data[:user_id]          = picture.user_id
      data[:pictureable_id]   = picture.pictureable_id
      data[:pictureable_type] = picture.pictureable_type
      data[:file_type]        = picture.file_type
      data[:file_url]         = picture.file_url
    end

    return data
  end

  def company_detail(data = {})
    company = object.company
    if company.present?
      picture = company.picture

      data[:name]         = company.name
      data[:status]       = company.status
      data[:phone_number] = company.phone_number
      data[:full_address] = company.full_address
      data[:city]         = company.city
      data[:postcode]     = company.postcode
      data[:state]        = company.state
      data[:country]      = company.country
      data[:latitude]     = company.latitude
      data[:longitude]    = company.longitude
      data[:logo_url]     = picture.try(:file_url).try(:url)
    end

    return data
  end

  def coin_balance
    balance = object.coin_balance
    return "#{balance.try(:amount).to_i} Coins"
  end

  def notifications(data = [])
    notifications = object.notifications

    notifications.each do |notif|
      notification = {}
      notification[:id]             = notif.id
      notification[:notifable_type] = notif.notifable_type
      notification[:notifable_id]   = notif.notifable_id
      notification[:message]        = notif.message
      notification[:status]         = notif.status
      notification[:amount]         = notif.amount
      notification[:reduce_coin]    = notif.reduce_coin
      notification[:created_at]     = notif.created_at
      notification[:updated_at]     = notif.updated_at

      data << notification
    end

    data
  end

end