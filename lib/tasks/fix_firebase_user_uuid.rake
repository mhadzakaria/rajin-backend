namespace :xxx do
  task(:fix_firebase_user_uuid => :environment) do
    
    users = User.where(firebase_user_uid: nil)
    users.each do |user|
      data = {
        email: user.email,
        password: user.password_firebase,
        returnSecureToken: true,
        key: ENV['FIREBASE_APIKEY']
      }
  
      params = {
        url: "https://identitytoolkit.googleapis.com/v1/accounts:signUp",
        headers: {},
        additional_path: "?#{data.to_param}"
      }

      uri  = URI.parse(params[:url])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new("#{uri.path}#{params[:additional_path]}", params[:headers])

      if params[:body_needed]
        request.body = params[:data].to_json
      end

      response = http.request(request)
      body = JSON.parse(response.body)

      if response.code.to_i == 200
        user.update!(firebase_user_uid: body['localId'])
        puts "Fixed for user #{user.email} -> #{user.firebase_user_uid}"
      end
    end
  end
end