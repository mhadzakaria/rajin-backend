class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  geocoded_by :full_address
  reverse_geocoded_by :latitude, :longitude

  after_validation :geocode, :if => lambda{ |obj| obj.full_address_changed? and obj.full_address.downcase != "world wide" } # auto-fetch coordinates

  before_create :generate_access_token

  def generate_access_token
    self.access_token = SecureRandom.hex(16)
  end

end
