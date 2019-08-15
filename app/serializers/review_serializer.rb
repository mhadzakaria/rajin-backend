class ReviewSerializer < ApplicationSerializer
  attributes :id, :user_id, :sender_detail, :job_id, :comment, :rate, :job_detail

  def job_detail
    job          = object.job
    data         = job_details(job)

    return data
  end

  def sender_detail
    user   = object.sender
    return user_more_details(user)
  end
end
