class UserSerializer < ApplicationSerializer
  attributes :id, :nickname, :first_name, :last_name, :email, :phone_number, :date_of_birth, :gender, :full_address, :city, :postcode, :state, :country, :latitude, :longitude, :user_type, :access_token, :uuid, :password, :config, :verified, :skills, :avatar, :company_detail, :coin_balance, :average_rating, :notifications, :role, :count_of_completed_job, :count_of_offer_job, :description, :twitter, :facebook, :linkedin, :instagram

  attribute :notifications,     if: :is_not_current_user
  attribute :role,              if: :is_not_current_user
  attribute :access_token,      if: :is_not_current_user
  attribute :uuid,              if: :is_not_current_user
  attribute :password,          if: :is_not_current_user
  attribute :config,            if: :is_not_current_user
  attribute :uploaded_pictures, if: :is_not_current_user

  def uploaded_pictures(pictures = [])
    if object.uploaded_pictures.present?
      object.uploaded_pictures.each do |picture|
        next if picture.file_url.blank?

        data = {
          :id        => picture.id,
          :file_type => picture.file_type,
          :file_url  => picture_details(picture.file_url)
        }

        pictures << data
      end
    end

    return pictures
  end

  def is_not_current_user
    !@instance_options[:not_current_user]
  end

  def password
    object.password || "Password not displayed"
  end

  def nickname
    object.get_nickname
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
    level_skills = object.level_skills

    level_skills.each do |level|
      skill                  = level.skill
      picture                = skill.picture
      datum                  = {}

      datum[:id]        = skill.id
      datum[:name]      = skill.name
      datum[:level]     = level.level
      datum[:file_type] = picture.try(:file_type)
      datum[:file_url]  = if picture.try(:file_url)
        base_url + picture.file_url.url
      else
        ''
      end
      data << datum
    end

    return data
  end

  def avatar(data = {})
    picture = object.picture

    return picture.try(:file_url).present? ? base_url + picture.file_url.url : ''
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
      data[:logo_url]     = if picture.try(:file_url)
        base_url + picture.file_url.url
      else
        ''
      end
    end

    return data
  end

  def coin_balance
    balance = object.coin_balance
    return "#{balance.try(:amount).to_i} Coins"
  end

  def notifications(data = [])
    notifications = object.notifications.showable

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

  def role(data = {})
    role = object.role
    unless role.blank?
      data[:id]          = role.id
      data[:role_name]   = role.role_name
      data[:role_code]   = role.role_code
      data[:authorities] = role.authorities
      data[:status]      = role.status
    end

    return data
  end

  def count_of_completed_job
    job_requests = object.job_requests.accepted
    jobs = Job.where(id: job_requests.map(&:job_id)).completed

    jobs.count
  end

  def count_of_offer_job
    object.jobs.pending.count
  end

  def verified
    company = object.company

    if company.present?
      company.status.eql?('Verified') || company.status.eql?('v')
    else
      false
    end
  end

  def average_rating
    if object.reviews.present?
      sum  = object.reviews.map(&:rate).sum
      size = object.reviews.count

      return (sum / size) rescue 0
    else
      return 0
    end
  end

end