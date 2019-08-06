class ChatSessionSerializer < ApplicationSerializer
  attributes :id, :job_detail, :chat_session_status, :job_applier_detail, :job_owner_detail, :job_request, :firebase_url

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
    data[:duration]        = job.duration
    data[:job_category]    = category_detail(job_category)
    data[:required_skills] = skill_with_picture(skills)
    data[:pictures]        = picture_details_list(pictures)

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
