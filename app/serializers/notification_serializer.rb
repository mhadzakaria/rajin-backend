class NotificationSerializer < ApplicationSerializer
  attributes :id, :user_detail, :notifable_type, :notifable_id, :message, :status, :amount, :reduce_coin, :notifable, :created_at, :updated_at

  def user_detail
    user = object.user
    return user_details(user)
  end

  def notifable
    data = object.notifable
    case object.notifable_type
    when 'JobRequest'
      data = {
        :id                 => object.notifable.id,
        :job_detail         => job_detail,
        :job_request_status => job_request_status,
        :job_applier_detail => job_applier_detail,
        :job_owner_detail   => job_owner_detail,
        :chat_sessions      => chat_sessions(object.notifable)
      }
    end

    data
  end

  def chat_sessions(job_request, data = nil)
    chat_sessions = job_request.chat_session
    if !chat_sessions.blank?
      data = chat_sessions
    end

    data
  end

  def job_detail(data = {})
    job          = object.notifable.job
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

  def job_request_status
    return object.notifable.status
  end

  def job_applier_detail
    user   = object.notifable.user
    return user_details(user)
  end

  def job_owner_detail
    job   = object.notifable.job
    owner = job.ownerable

    return user_details(owner)
  end
end
