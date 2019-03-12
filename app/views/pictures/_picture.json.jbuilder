json.extract! picture, :id, :user_id, :pictureable_type, :pictureable_id, :file_url, :file_type, :created_at, :updated_at
json.url picture_url(picture, format: :json)
