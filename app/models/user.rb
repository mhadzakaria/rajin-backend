class User < ApplicationRecord
  include Geocoderable
  serialize :skill_ids, Array
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true
  belongs_to :role, optional: true

  has_many  :reviews
  has_many  :given_reviews, foreign_key: :sender_id, class_name: "Review"
  has_many  :jobs, as: :ownerable
  has_many  :job_requests
  has_many  :notifications
  has_many  :orders
  has_many  :school_applies
  has_many  :chat_sessions
  has_many  :my_job_chat_sessions, foreign_key: :user_job_id, class_name: "ChatSession"

  has_one   :subscription_package, dependent: :destroy
  has_one   :coin_balance, dependent: :destroy
  has_one   :config, dependent: :destroy
  has_one   :picture, as: :pictureable, dependent: :destroy
  has_many  :uploaded_pictures, class_name: "Picture", foreign_key: :user_id, dependent: :destroy

  paginates_per 10

  before_create :generate_access_token
  after_create  :generate_default_config

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

  def generate_default_config
    if self.config.blank?
      config               = self.build_config
      config.email_notif   = true
      config.receive_notif = true
      config.save
    end
  end

  def skills
    skills = Skill.where(id: self.skill_ids)

    return skills
  end
end
