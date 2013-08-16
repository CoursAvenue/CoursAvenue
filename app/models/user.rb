class User < ActiveRecord::Base

  extend FriendlyId
  friendly_id :full_name, use: [:slugged, :history]

  has_many :comments
  has_many :reservations

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
                  :first_name, :last_name, :fb_avatar, :location, :avatar

  validates :first_name, :last_name, :email, presence: true

  has_attached_file :avatar,
                    styles: { wide: '800x800#', normal: '450x', thumb: '200x200#', small: '100x100#', mini: '40x40#' }#,
                    # path: 'assets/users/:id/avatar/:fingerprint-:style.:extension'

  # after_save :subscribe_to_mailchimp if Rails.env.production?
  after_create :associate_all_comments

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider           = auth.provider
      user.uid                = auth.uid
      user.oauth_token        = auth.credentials.token
      user.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      user.first_name         = auth.info.first_name
      user.last_name          = auth.info.last_name
      user.email              = auth.info.email
      user.fb_avatar          = auth.info.image
      user.location           = auth.info.location
      user.password           = Devise.friendly_token[0,20]
      user.save!
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # Type in: small square large normal
  def fb_avatar(type='square')
    self.read_attribute(:fb_avatar).split("=")[0] << "=#{type}" unless self.read_attribute(:fb_avatar).nil?
  end

  def reservation_for?(reservable)
    self.reservations.exists?(reservable_id: reservable.id, reservable_type: (reservable.is_a?(Course) ? 'Course' : reservable.class.name))
  end

  private

  def associate_all_comments
    _email   = self.email
    _user_id = self.id
    Comment.where(email: _email).each do |comment|
      comment.update_column(:user_id, _user_id)
    end
  end

  def subscribe_to_mailchimp
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_USERS_LIST_ID,
                           :email_address => self.email,
                           :merge_vars => {
                              :NAME => self.full_name,
                              :STATUS => 'registered'
                           },
                           :double_optin => false,
                           :update_existing => true,
                           :send_welcome => false})
  end
end
