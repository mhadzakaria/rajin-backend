class Company < ApplicationRecord
	has_one :picture, as: :pictureable
  has_many :users
end
