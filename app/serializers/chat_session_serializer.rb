class ChatSessionSerializer < ApplicationSerializer
  attributes :id, :job_detail, :chat_session_status, :job_applier_detail, :job_owner_detail, :job_request, :firebase_url

  def job_detail
    job = object.job

    return job_details(job)
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
