class ChatSession < ApplicationRecord
  belongs_to :user
  belongs_to :user_job, foreign_key: "user_job_id", class_name: 'User'
  belongs_to :job_request

  enum status: { opened: 0, closed: 1 }

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
    base_uri = "https://rajin-production.firebaseio.com/"
    firebase = Firebase::Client.new(base_uri)
    data = {
      id: current_user.id,
      name: current_user.email,
      text: params[:text],
      time: DateTime.now.strftime('%D %T %Z'),
      read: true
    }

    response = firebase.push(provider_url, data)
    if response.success?

      push_notif_chat(params, current_user)
      # response.code # => 200
      # response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
      # response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'
      result = {
        status: response.code,
        data:   data
      }
    else
    end

    return result
  end

  def push_notif_chat(params, current_user)
    # https://devcenter.heroku.com/articles/procfile#procfile-naming-and-location
    # https://devcenter.heroku.com/articles/delayed-job#setting-up-delayed-job
    url  = "https://fcm.googleapis.com/fcm/send"
    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    receiver = if current_user.id.eql?(user_id)
      current_user.uuid
    else
      user_job.uuid
    end

    data = {
      notification: {
        title: current_user.full_name,
        body: params[:text]
      },
      to: receiver
    }

    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "key=AIzaSyAvpGMIeNOekmmHxCx5WkdTm9w2zoQvLeI"})
    request.body = data.to_json

    response = http.request(request)
  end

end
