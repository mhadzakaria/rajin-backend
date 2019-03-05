class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :companies
  has_many  :reviews
  has_many  :jobs
  has_many  :job_requests
  has_many  :skills
  has_many  :notifications
  has_many  :orders
  has_many  :school_applies
  has_one   :subscription_package
  has_one   :coin_balance
  has_one   :config
  has_one   :picture, as: :pictureable

  geocoded_by :full_address
  reverse_geocoded_by :latitude, :longitude

  after_validation :geocode, :if => lambda{ |obj| obj.full_address_changed? and obj.full_address.downcase != "world wide" } # auto-fetch coordinates

  before_create :generate_access_token

  def generate_access_token
    self.access_token = SecureRandom.hex(16)
  end

end
