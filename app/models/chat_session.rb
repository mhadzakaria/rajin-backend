class ChatSession < ApplicationRecord
  belongs_to :user
  belongs_to :user_job, foreign_key: "user_job_id", class_name: 'User'
  belongs_to :job_request

  enum status: { opened: 0, closed: 1 }

  after_create :initialize_firebase_chat

  default_scope { order(created_at: :desc) }

  scope :owner_job,   ->(user_id) {where(user_job_id: user_id)}
  scope :normal_user, ->(user_id) {where(user_id: user_id)}
  scope :my_chat,     ->(user_id) {where("user_id = ? or user_job_id = ?", user_id, user_id)}
  scope :open_chat,   -> { where(status: 'opened') }
  scope :close_chat,  -> { where(status: 'closed') }

  def job
    self.job_request.job
  end

  def build_firebase_key(job_id)
    random_key   = SecureRandom.hex(10)
    firebase_key = "job_request-#{job_request_id}-#{job_id}-#{random_key}"

    self.provider_url = firebase_key
  end

  def store_chat(params, current_user)
    # https://firebase.google.com/docs/database/rest/start
    data = {
      id: current_user.id,
      name: current_user.email,
      text: params[:text],
      read: false,
      time: DateTime.now.strftime('%D %T %Z')
    }
    base_uri   = ENV['FIREBASE_URL']
    user_token = sign_in(current_user)
    token      = user_token["idToken"]

    url  = "#{base_uri}chats/#{provider_url}/messages.json"
    uri  = URI(url)

    http         = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request      = Net::HTTP::Post.new("#{uri.path}?auth=#{token}")
    request.body = data.to_json
    response     = http.request(request)

    if response.code.eql?("200")
      self.delay.push_notif_chat(params, current_user, data)

      result = {
        status: response.code,
        data:   data
      }
    else
      if response.code.eql?("401")
        user_details = user_details(user_token["refreshToken"])

        url_part     = url.gsub("messages", "participants")
        uri_part     = URI(url_part)

        http         = Net::HTTP.new(uri_part.host, uri_part.port)
        http.use_ssl = true

        request_part = Net::HTTP::Get.new("#{uri_part.path}?auth=#{token}")
        respon_part  = http.request(request_part)
        json         = JSON.parse(respon_part.response.body)

        json.each do |uid, val|
          if uid.eql?(current_user.email.gsub('.', '-'))
            data_new_part = {
              uid => {
                name: current_user.full_name,
                uid: "#{user_details['user_id']}"
              }
            }

            req_new_part      = Net::HTTP::Patch.new("#{uri_part.path}?auth=#{token}")
            req_new_part.body = data_new_part.to_json
            res_new_part      = http.request(req_new_part)

            response     = http.request(request)
            if response.code.eql?("200")
              result = {
                status: response.code,
                data:   data
              }
            else
              result = {
                status: response.code,
                data:   response.message
              }
            end
          end
        end
      else
        result = {
          status: response.code,
          data:   response.message
        }
      end
    end

    return result
  end

  def initialize_firebase_chat
    user_1 = sign_in(user)
    user_2 = sign_in(user_job)

    details_1 = user_details(user_1["refreshToken"])
    details_2 = user_details(user_2["refreshToken"])
    data      = {
      user.email.gsub('.', '-') => {
        name: user.full_name,
        uid: details_1["user_id"]
      },
      user_job.email.gsub('.', '-') => {
        name: user_job.full_name,
        uid: details_2["user_id"]
      }
    }
    base_uri = ENV['FIREBASE_URL']
    url      = "#{base_uri}chats/#{provider_url}/participants.json"
    uri      = URI(url)


    http         = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request      = Net::HTTP::Patch.new("#{uri.path}?auth=#{user_1["idToken"]}")
    request.body = data.to_json
    response     = http.request(request)

    if response.code.eql?("200")
      result = {
        status: response.code,
        data:   data
      }
    else
      result = {
        status: response.code,
        data:   response.message
      }

      self.errors.add(:firebase_error, ": #{response.message}")
      raise ActiveRecord::Rollback
    end

    puts result
  end

  def user_details(refresh_token)
    data = {
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      key: ENV['FIREBASE_APIKEY']
    }

    params = {
      url: "https://securetoken.googleapis.com/v1/token",
      headers: {},
      additional_path: "?#{data.to_param}"
    }

    response = net_http_post(params)
    JSON.parse(response.body)
  end

  def sign_in(current_user)
    if current_user.password_firebase.blank?
      current_user.generate_password_firebase(true)
      current_user.reload
    end

    data = {
      email: current_user.email,
      password: current_user.password_firebase,
      returnSecureToken: true,
      key: ENV['FIREBASE_APIKEY']
    }

    params = {
      url: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword",
      headers: {},
      additional_path: "?#{data.to_param}"
    }

    response = net_http_post(params)
    result = JSON.parse(response.body)

    if result["error"].present? && result["error"]["errors"].map{|c| c["message"]}.include?("EMAIL_NOT_FOUND")
      sign_up(current_user)
    else
      result
    end
  end

  def sign_up(current_user)

    data = {
      email: current_user.email,
      password: current_user.password_firebase,
      returnSecureToken: true,
      key: ENV['FIREBASE_APIKEY']
    }

    params = {
      url: "https://identitytoolkit.googleapis.com/v1/accounts:signUp",
      headers: {},
      additional_path: "?#{data.to_param}"
    }

    response = net_http_post(params)
    body = JSON.parse(response.body)

    if response.code.to_i == 200
      current_user.update!(firebase_user_uid: body['localId'])
    end
    
    body
  end

  def push_notif_chat(params, current_user, message)
    # https://devcenter.heroku.com/articles/procfile#procfile-naming-and-location
    # https://devcenter.heroku.com/articles/delayed-job#setting-up-delayed-job
    receiver = if current_user.id.eql?(user_id)
      user_job.uuid
    else
      user.uuid
    end

    data = {
      data: {
        id: id,
        message: message
      },
      notification: {
        title: current_user.full_name,
        body: params[:text]
      },
      to: receiver
    }

    cloud_message_key = if Rails.env.eql?('production')
      'AIzaSyAvpGMIeNOekmmHxCx5WkdTm9w2zoQvLeI'
    else
      'AIzaSyCkkwoQWA6XsT3_aSmTa8URPrVUJy1aYHs'
    end

    params = {
      url: "https://fcm.googleapis.com/fcm/send",
      data: data,
      headers: {'Content-Type' => 'application/json', 'Authorization' => "key=#{cloud_message_key}"},
      body_needed: true
    }

    net_http_post(params)
  end

  def net_http_post(params)
    uri  = URI.parse(params[:url])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new("#{uri.path}#{params[:additional_path]}", params[:headers])

    if params[:body_needed]
      request.body = params[:data].to_json
    end

    http.request(request)
  end

end
