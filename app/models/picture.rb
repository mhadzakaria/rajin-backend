class Picture < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :pictureable, polymorphic: true

  mount_uploader :file_url, PictureUploader
end
