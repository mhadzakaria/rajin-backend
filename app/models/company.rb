class Company < ApplicationRecord
  include Geocoderable

  has_one  :picture, as: :pictureable
  has_many :users
end
