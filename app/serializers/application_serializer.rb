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
      file_url = avatar.try(:file_url)
      data[:avatar_url] = if file_url.present?
        base_url + file_url.url
      else
        ''
      end
      data[:coin_balance] = "#{balance.try(:amount).to_i} Coins"
    end

    return data
  end

  def base_url
    "#{@instance_options[:base_url]}"
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

  def skill_with_picture(skills, result = [])
    skills.each do |skill|
      datum = {}
      file_url = skill.picture.try(:file_url)

      datum[:name]    = skill.name
      datum[:picture] = if file_url.present?
        base_url + file_url.url
      else
        ''
      end

      result << datum
    end

    result
  end

  def picture_details_list(pictures, result = [])
    pictures.each do |picture|
      datum = {}
      file_url = picture.file_url

      datum[:file_url] = if file_url.present?
        base_url + file_url.url
      else
        ''
      end
      datum[:file_type] = picture.file_type

      result << datum
    end

    result
  end

  def picture_details(file_url)
    if file_url.present?
      {
        url: base_url + file_url.url,
        thumb: {
          url: base_url + file_url.thumb.url
        }
      }
    else
      {}
    end
  end
end