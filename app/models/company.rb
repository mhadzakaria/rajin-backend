class Company < ApplicationRecord
  include Geocoderable

  has_one  :picture, as: :pictureable
  has_many :users

  paginates_per 10

  scope :verified, -> { where(status: "v") }

  enum status: {"Pending" => "p", "Active" => "a", "Verified" => "v"}

  def self.export(companies)
    attributes = ["name", "status", "phone_number", "full_address", "city", "postcode", "state", "country", "latitude", "longitude", "created_at", "updated_at"]
    to_csv(companies, attributes)
  end
end
