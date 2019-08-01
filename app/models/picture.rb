class Picture < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :pictureable, polymorphic: true, optional: true

  mount_base64_uploader :file_url, PictureUploader

  paginates_per 10
end
