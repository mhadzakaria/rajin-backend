class Company < ApplicationRecord
  include Geocoderable

  has_one  :picture, as: :pictureable
  has_many :users

  paginates_per 10
end
