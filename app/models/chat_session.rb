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
    puts "store_chat========================================================================"
    # https://firebase.google.com/docs/database/rest/start
    data = {
      id: current_user.id,
      name: current_user.email,
      text: params[:text],
      time: DateTime.now.strftime('%D %T %Z')
    }
    base_uri   = Rails.application.secrets.firebase_url
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
      self.delay.push_notif_chat(params, current_user)

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

    return result
  end

  def initialize_firebase_chat
    puts "initialize_firebase_chat========================================================================"
    user_1 = sign_in(user)
    user_2 = sign_in(user_job)

    details_1 = user_details(user_1["refreshToken"])
    details_2 = user_details(user_2["refreshToken"])
    data = {"#{provider_url}" => {participants: {details_1["user_id"] => {name: user.full_name},details_2["user_id"] => {name: user_job.full_name}}}}
    base_uri = Rails.application.secrets.firebase_url
    url      = "#{base_uri}chats.json"
    uri      = URI(url)


    http         = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request      = Net::HTTP::Patch.new("#{uri.path}?auth=#{user_1["idToken"]}")
    request.body = data.to_json
    response     = http.request(request)
debugger
# {
#   "job_request-11-10-a5b54647c25fc65b705a": {
#     "participants":{
#       "xc3a8DCPaDNVV61ArXuLV16uYln2":{
#         "name": "Indra Sinaga EDIT"
#       },
#       "GoLqX6cYOjZ2R6cXitgqHskQyJG2":{
#         "name": "Elvin Alvian"
#       }
#     }
#   }
# }
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

    puts result
  end

  def user_details(refresh_token)
    puts "user_details========================================================================"
    data = {
      grant_type: "refresh_token",
      refresh_token: refresh_token,
      key: Rails.application.secrets.firebase_apiKey
    }

    # url  = "https://securetoken.googleapis.com/v1/token"
    # uri  = URI(url)
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true

    # request = Net::HTTP::Post.new("#{uri.path}?#{data.to_param}")

    # response = http.request(request)

    # JSON.parse(response.body)

    params = {
      url: "https://securetoken.googleapis.com/v1/token",
      headers: {},
      additional_path: "?#{data.to_param}"
    }

    response = net_http_post(params)
    JSON.parse(response.body)
  end

  def sign_in(current_user)
    puts "sign_in========================================================================"
    puts "SIGN-IN=========================="
    if current_user.password_firebase.blank?
      current_user.generate_password_firebase(true)
      current_user.reload
    end

    data = {
      email: current_user.email,
      password: current_user.password_firebase,
      returnSecureToken: true,
      key: Rails.application.secrets.firebase_apiKey
    }

    # url  = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword"
    # uri  = URI(url)
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true

    # request = Net::HTTP::Post.new("#{uri.path}?#{data.to_param}")

    # response = http.request(request)
    # result = JSON.parse(response.body)

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
    puts "sign_up========================================================================"
    puts "SIGN-UP=========================="
    # if current_user.password_firebase.blank?
    #   current_user.generate_password_firebase(true)
    #   current_user.reload
    # end

    data = {
      email: current_user.email,
      password: current_user.password_firebase,
      returnSecureToken: true,
      key: Rails.application.secrets.firebase_apiKey
    }

    # url  = "https://identitytoolkit.googleapis.com/v1/accounts:signUp"
    # uri  = URI(url)
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true

    # request = Net::HTTP::Post.new("#{uri.path}?#{data.to_param}")

    # response = http.request(request)

    # JSON.parse(response.body)

    params = {
      url: "https://identitytoolkit.googleapis.com/v1/accounts:signUp",
      headers: {},
      additional_path: "?#{data.to_param}"
    }

    response = net_http_post(params)
    JSON.parse(response.body)
  end

  def push_notif_chat(params, current_user)
    puts "push_notif_chat========================================================================"
    # https://devcenter.heroku.com/articles/procfile#procfile-naming-and-location
    # https://devcenter.heroku.com/articles/delayed-job#setting-up-delayed-job
    url  = "https://fcm.googleapis.com/fcm/send"
    # uri  = URI.parse(url)
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true

    receiver = if current_user.id.eql?(user_id)
      user_job.uuid
    else
      user.uuid
    end

    data = {
      notification: {
        title: current_user.full_name,
        body: params[:text]
      },
      to: receiver
    }

    # request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "key=AIzaSyAvpGMIeNOekmmHxCx5WkdTm9w2zoQvLeI"})
    # request.body = data.to_json

    # response = http.request(request)
    params = {
      url: "https://fcm.googleapis.com/fcm/send",
      data: data,
      headers: {'Content-Type' => 'application/json', 'Authorization' => "key=AIzaSyAvpGMIeNOekmmHxCx5WkdTm9w2zoQvLeI"},
      body_needed: true
    }

    net_http_post(params)
  end

  def net_http_post(params)
    puts "net_http_post========================================================================"
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
