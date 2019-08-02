class OrderSerializer < ApplicationSerializer
  attributes :id, :full_id, :status, :amount, :net_amount, :payment_id, :payment_gateway, :payment_method, :user_detail, :orderable, :created_at

  def user_detail(data = {})
    user = object.user
    return user_details(user)
  end

  def orderable(data = {})
    orderable = object.orderable
    case orderable.class.name
    when "CoinPackage"
      data[:id]     = orderable.id
      data[:coin]   = orderable.coin
      data[:amount] = orderable.amount
    when "Job"
      skills       = orderable.skills
      job_category = orderable.job_category
      pictures     = orderable.pictures

      data[:id]              = orderable.id
      data[:title]           = orderable.title
      data[:description]     = orderable.description
      data[:payment_term]    = orderable.payment_term
      data[:amount]          = orderable.amount
      data[:payment_type]    = orderable.payment_type
      data[:full_address]    = orderable.full_address
      data[:city]            = orderable.city
      data[:postcode]        = orderable.postcode
      data[:state]           = orderable.state
      data[:country]         = orderable.country
      data[:start_date]      = orderable.start_date
      data[:end_date]        = orderable.end_date
      data[:latitude]        = orderable.latitude
      data[:longitude]       = orderable.longitude
      data[:status]          = orderable.status
      data[:duration]        = orderable.duration
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
    end

    return data
  end
end