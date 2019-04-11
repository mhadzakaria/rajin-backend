class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :user_detail, :notifable_type, :notifable_id, :message, :status, :amount, :reduce_coin, :created_at, :updated_at

  def user_detail(data = {})
    user    = object.user
    avatar  = user.picture
    balance = user.coin_balance

    data[:id]           = user.id
    data[:nickname]     = user.nickname
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
    data[:avatar_url]   = avatar.try(:file_url).try(:url)
    data[:coin_balance] = "#{balance.try(:amount).to_i} Coins"

    return data
  end
end
