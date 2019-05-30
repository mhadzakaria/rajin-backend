class ChatSessionSerializer < ApplicationSerializer
  attributes :id, :job_detail, :chat_session_status, :job_applier_detail, :job_owner_detail, :firebase_url

  def job_detail(data = {})
    job          = object.job
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
    data[:job_category]    = job_category.name
    data[:required_skills] = []
    data[:pictures]        = []

    skills.each do |skill|
      datum = {}
      datum[:name]    = skill.name
      datum[:picture] = skill.picture.try(:file_url).try(:url)

      data[:required_skills] << datum
    end

    pictures.each do |picture|
      datum = {}
      datum[:file_url]  = picture.file_url.url
      datum[:file_type] = picture.file_type

      data[:pictures] << datum
    end

    return data
  end

  def chat_session_status
    return object.status
  end

  def job_applier_detail
    user   = object.user
    return user_details(user)
  end

  def job_owner_detail
    job   = object.job
    owner = job.ownerable

    return user_details(owner)
  end

  def firebase_url
    return object.provider_url
  end

end
