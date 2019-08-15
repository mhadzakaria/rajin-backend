class ApplicationSerializer < ActiveModel::Serializer
  include ApplicationHelper

  def user_details(user, data = {})
    avatar  = user.picture
    balance = user.coin_balance

    unless user.blank?
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
      file_url = avatar.try(:file_url)
      data[:avatar_url] = if file_url.present?
        base_url + file_url.url
      else
        ''
      end
      data[:coin_balance] = "#{balance.try(:amount).to_i} Coins"
    end

    return data
  end

  def job_details(job, data = {})
    skills       = job.skills
    job_category = job.job_category
    pictures     = job.pictures

    data[:id]              = job.id
    data[:title]           = job.title
    data[:description]     = job.description
    data[:payment_term]    = job.payment_term
    data[:amount]          = job.amount
    data[:payment_type]    = job.payment_type
    data[:full_address]    = job.full_address
    data[:city]            = job.city
    data[:postcode]        = job.postcode
    data[:state]           = job.state
    data[:country]         = job.country
    data[:start_date]      = job.start_date
    data[:end_date]        = job.end_date
    data[:latitude]        = job.latitude
    data[:longitude]       = job.longitude
    data[:status]          = job.status
    data[:duration]        = job.duration
    data[:is_promoted]     = job.is_promoted
    data[:job_category]    = category_detail(job_category)
    data[:required_skills] = skill_with_picture(skills)
    data[:pictures]        = picture_details_list(pictures)

    return data
  end

  def base_url
    "#{@instance_options[:base_url]}"
  end

  def category_detail(category)
    data     = {}

    unless category.blank?
      parent   = category.parent

      data[:id]   = category.id
      data[:name] = category.name

      data[:main_category] = {
          id: parent.id,
        name: parent.name
      } if parent.present?
    end

    return data 
  end

  def skill_with_picture(skills, result = [])
    skills.each do |skill|
      datum = {}
      file_url = skill.picture.try(:file_url)

      datum[:name]    = skill.name
      datum[:picture] = if file_url.present?
        base_url + file_url.url
      else
        ''
      end

      result << datum
    end

    result
  end

  def picture_details_list(pictures, result = [])
    pictures.each do |picture|
      datum = {}
      file_url = picture.file_url

      datum[:file_url] = if file_url.present?
        base_url + file_url.url
      else
        ''
      end
      datum[:file_type] = picture.file_type

      result << datum
    end

    result
  end

  def picture_details(file_url)
    if file_url.present?
      base_url + file_url.url
    else
      ''
    end
  end

  def user_more_details(user)
    data     = user_details(user)
    file_url = user.picture.try(:file_url)

    data[:user_type]              = user.user_type
    data[:verified]               = verified(user)
    data[:skills]                 = skills(user)
    data[:company_detail]         = company_detail(user)
    data[:average_rating]         = average_rating(user)
    data[:count_of_completed_job] = count_of_completed_job(user)
    data[:count_of_offer_job]     = count_of_offer_job(user)
    data[:description]            = user.description
    data[:twitter]                = user.twitter
    data[:facebook]               = user.facebook
    data[:linkedin]               = user.linkedin
    data[:instagram]              = user.instagram
    data[:uploaded_pictures]      = uploaded_pictures(user)

    return data
  end

  def average_rating(user)
    if user.reviews.present?
      sum  = user.reviews.map(&:rate).sum
      size = user.reviews.count

      return (sum / size) rescue 0
    else
      return 0
    end
  end

  def skills(user, data = [])
    level_skills = user.level_skills

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

  def uploaded_pictures(user, pictures = [])
    if user.uploaded_pictures.present?
      user.uploaded_pictures.each do |picture|
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

  def company_detail(user, data = {})
    company = user.company
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

  def coin_balance(user)
    balance = user.coin_balance
    return "#{balance.try(:amount).to_i} Coins"
  end

  def count_of_completed_job(user)
    job_requests = user.job_requests.accepted
    jobs = Job.where(id: job_requests.map(&:job_id)).completed

    jobs.count
  end

  def count_of_offer_job(user)
    user.jobs.pending.count
  end

  def verified(user)
    company = user.company

    if company.present?
      company.status.eql?('Verified') || company.status.eql?('v')
    else
      false
    end
  end

end