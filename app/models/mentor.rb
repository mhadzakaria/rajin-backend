class Mentor < ApplicationRecord
  include Geocoderable
  serialize :skill_ids, Array

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # belongs_to :company, optional: true

  has_many  :school_applies
  has_one   :picture, as: :pictureable, dependent: :destroy

  paginates_per 10

  before_create :generate_access_token

  ransacker :full_name do |parent|
    Arel::Nodes::InfixOperation.new(
      '||',
      Arel::Nodes::InfixOperation.new(
        '||',
        parent.table[:first_name], Arel::Nodes.build_quoted(' ')
      ),
      parent.table[:last_name]
    )
  end

  def generate_access_token
    self.access_token = SecureRandom.hex(16)
  end

  def skills
    skills = Skill.where(id: self.skill_ids)

    return skills
  end
end