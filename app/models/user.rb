class User < ApplicationRecord
  include Geocoderable
  attr_accessor :skip_password_validation  # virtual attribute to skip password validation while saving

  serialize :skill_ids, Array
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :invitable,
         :omniauthable, :omniauth_providers => [:facebook]

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
  has_many  :level_skills, dependent: :destroy
  has_many  :skills, through: :level_skills


  has_one   :subscription_package, dependent: :destroy
  has_one   :coin_balance, dependent: :destroy
  has_one   :config, dependent: :destroy
  has_one   :picture, as: :pictureable, dependent: :destroy
  has_many  :uploaded_pictures, class_name: "Picture", foreign_key: :user_id, dependent: :destroy

  validates_presence_of :first_name, :last_name, :nickname
  validates_uniqueness_of :nickname, :email
  validates :email, format: { with: /(\A([a-z]*\s*)*\<*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\>*\Z)/i }
  validates_format_of :nickname, { :with => /\A[A-Za-z0-9._-]*\z/, :message => 'no special characters, except number, "-", "_", ".", and "@" on first text.' }

  paginates_per 10

  before_create :generate_access_token
  after_create  :generate_default_config, :generate_password_firebase
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

  def generate_password_firebase(blank_password = false)
    self.password_firebase = SecureRandom.hex(16)

    if blank_password
      save
    else
      sign_up_firebase(self)
    end
    # Shoud create user at firebase here, upon successful registration
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

  # def skills
  #   skills = Skill.where(id: self.skill_ids)

  #   return skills
  # end

  def self.export(users)
    attributes = ["email", "nickname", "first_name", "last_name", "phone_number", "date_of_birth", "gender", "full_address", "city", "postcode", "state", "country", "company_csv", "role_csv", "latitude", "longitude", "user_type", "skill_csv", "created_at", "updated_at"]
    to_csv(users, attributes)
  end

  def role_csv
    self.role.try(:role_name)
  end

  def company_csv
    self.company.try(:name)
  end

  def skill_csv
    self.skills.map(&:name).to_sentence
  end

  def get_nickname
    return "@#{self.nickname}"
  end

   def self.from_omniauth(auth)
    unless auth.blank?
      user   = self.find_by(email: auth[:email])
      user ||= self.where(provider: auth[:provider], uid: auth[:uid]).first_or_initialize

      user.first_name = auth[:first_name]
      user.last_name  = auth[:last_name]
      user.nickname   = auth[:nickname]
      user.email      = auth[:email]
      user.uid        = auth[:uid]
      user.provider   = auth[:provider]

      if user.new_record? && user.valid?
        default_password = Devise.friendly_token[0,20]
        user.password    = default_password
        NotificationMailer.send_user_current_password(user, default_password).deliver
      end

      return user
    end
  end

  def coordinates
    return [self.latitude, self.longitude]
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  def generate_nickname
    nkname = nickname.to_s rescue ''
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
