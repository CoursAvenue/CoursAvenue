class User < ActiveRecord::Base

  extend FriendlyId
  friendly_id :full_name, use: [:slugged, :history]

  has_many :comments

  has_and_belongs_to_many :plannings
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :places

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :oauth_token, :oauth_expires_at,
                  :first_name, :last_name, :image, :location

  validates :first_name, :last_name, :email, presence: true

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider           = auth.provider
      user.uid                = auth.uid
      user.oauth_token        = auth.credentials.token
      user.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      user.first_name         = auth.info.first_name
      user.last_name          = auth.info.last_name
      user.image              = auth.info.image
      user.location           = auth.info.location
      user.save!
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
