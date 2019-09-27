class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.to_csv(records, attributes)
    CSV.generate(headers: true) do |csv|
      csv << attributes.map{|a| a.remove('_csv').titleize }

      records.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def json_delete_timestamp
    attribute = self.attributes
    attribute.delete('created_at')
    attribute.delete('updated_at')
    attribute
  end

  def sign_up_firebase(current_user)
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
    puts body

    if response.code.to_i == 200
      current_user.update!(firebase_user_uid: body['localId'])
    end

    body
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
