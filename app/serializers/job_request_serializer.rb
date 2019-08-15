class JobRequestSerializer < ApplicationSerializer
  attributes :id, :job_detail, :job_request_status, :job_applier_detail, :job_owner_detail, :chat_session

  def job_detail
    job          = object.job
    data         = job_details(job)

    return data
  end

  def job_request_status
    return object.status
  end

  def job_applier_detail
    user   = object.user
    return user_more_details(user)
  end

  def job_owner_detail
    job   = object.job
    owner = job.ownerable

    return user_details(owner)
  end

end
