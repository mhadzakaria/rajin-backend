class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :sender_id, :job_id, :comment, :rate, :job_detail, :job_owner_detail

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

  def job_owner_detail(data = {})
    job  = object.job
    owner = job.ownerable
    avatar = owner.picture

    data[:id]           = owner.id
    data[:nickname]     = owner.nickname
    data[:first_name]   = owner.first_name
    data[:last_name]    = owner.last_name
    data[:email]        = owner.email
    data[:phone_number] = owner.phone_number
    data[:full_address] = owner.full_address
    data[:city]         = owner.city
    data[:postcode]     = owner.postcode
    data[:state]        = owner.state
    data[:country]      = owner.country
    data[:latitude]     = owner.latitude
    data[:longitude]    = owner.longitude
    data[:avatar_url]   = avatar.try(:file_url).try(:url)
    # data[:company]    = user.company

    return data
  end
end
