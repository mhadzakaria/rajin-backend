class ApplicationSerializer < ActiveModel::Serializer
  include ApplicationHelper

  def user_details(user)
    data    = {}
    avatar  = user.picture
    balance = user.coin_balance

    unless user.blank?
      data[:id]           = user.id
      data[:nickname]     = user.get_nickname
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
    end

    return data
  end

  def category_detail(category)
    data     = {}

    unless category.blank?
      parent   = category.parent

      data[:id]    = category.id
      data[:title] = category.title

      data[:main_category] = {
           id: parent.id,
        title: parent.title
      } if parent.present?
    end

    return data 
  end
end