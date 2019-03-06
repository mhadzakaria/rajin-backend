class Mentor < ApplicationRecord
  include Geocoderable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # belongs_to :company, optional: true

  has_many  :school_applies

  before_create :generate_access_token

  def generate_access_token
    self.access_token = SecureRandom.hex(16)
  end

end