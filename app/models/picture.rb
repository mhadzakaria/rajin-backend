class Picture < ApplicationRecord
	belongs_to :pictureable, polymorphic: true
	belongs_to :user
end
