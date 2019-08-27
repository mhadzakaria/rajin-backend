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

  def job_detail
    job = object.notifable.job

    return job_details(job)
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
