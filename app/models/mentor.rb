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
  has_many  :jobs, as: :ownerable

  validates_presence_of :first_name, :last_name, :nickname
  validates_uniqueness_of :nickname
  validates_format_of :nickname, { :with => /\A[A-Za-z0-9._-]*\z/, :message => 'no special characters, except number, "-", "_", ".", and "@" on first text.' }

  paginates_per 10

  before_create :generate_access_token
  before_validation :generate_nickname

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

  def full_name
    name = "#{self.first_name} #{self.last_name}"
    name = "#{self.email}" if name.blank?

    return name
  end

  def skills
    skills = Skill.where(id: self.skill_ids)

    return skills
  end

  def get_nickname
    return "@#{self.nickname}"
  end

  private

    def generate_nickname
      nkname = nickname
      if !nkname.include?('@') || nkname.last.eql?('@')
        nickname = nkname
        return
      end

      spnkname = nkname.split('@')
      if spnkname.size > 2 || spnkname.size.eql?(1)
        nickname = nkname
        return
      end

      nickname = if spnkname.first.blank?
        spnkname.last
      else
        nkname
      end
    end
end