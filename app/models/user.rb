class User < ApplicationRecord
  include Geocoderable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true

  has_many  :reviews
  has_many  :given_reviews, foreign_key: :sender_id, class_name: "Review"
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

  before_create :generate_access_token

  def generate_access_token
    self.access_token = SecureRandom.hex(16)
  end

end
