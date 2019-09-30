namespace :firebase do
  desc "Register user to firebase"
  task(:fix_firebase_user_uuid => :environment) do

    users = User.where(firebase_user_uid: nil)
    users.each do |user|
      if user.password_firebase.blank?
        user.generate_password_firebase(true)
        user.reload
      end

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
        if user.update(firebase_user_uid: body['localId'])
          puts "Fixed for user #{user.email} -> #{user.firebase_user_uid}"
        else
          puts "Failed to save for user #{user.email} -> #{user.errors.full_messages.join('. ')}"
        end
      else
        sign_in_params = {
          url: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword",
          headers: {},
          additional_path: "?#{data.to_param}"
        }

        uri  = URI.parse(sign_in_params[:url])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new("#{uri.path}#{sign_in_params[:additional_path]}", sign_in_params[:headers])

        sign_in_response = http.request(request)
        sign_in_body     = JSON.parse(sign_in_response.body)
        puts sign_in_body
        if sign_in_response.code.to_i == 200
          user.update(firebase_user_uid: sign_in_body['localId'])
          puts "Fixed for user #{user.email} -> #{user.firebase_user_uid}"
        else
          puts "response body:"
          puts body
          puts "User #{user.email} already has firebase uuid"
        end
      end
    end
  end
end