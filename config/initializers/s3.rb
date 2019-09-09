CarrierWave.configure do |config|
  if Rails.env.staging? || Rails.env.production?
    config.fog_credentials = {
      :provider => 'AWS',
      :aws_access_key_id => 'AKIAZ65LAZYECDPMKYGU',
      :aws_secret_access_key => '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',
      :region => 'ap-southeast-1'
    }
    config.fog_directory  = 'rajin-prod'
  else
    config.enable_processing = Rails.env.development?
  end
end