class User < ActiveRecord::Base
  include ActsAsUnsubscribable
  include Rails.application.routes.url_helpers

  acts_as_messageable

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :comments, -> { order('created_at DESC') }
  has_many :reservations
  has_many :comment_notifications
  has_many :passions

  has_many :user_profiles
  has_many :structures, through: :user_profiles
  # has_and_belongs_to_many :subjects

  belongs_to :city

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :oauth_token, :oauth_expires_at,
                  :name, :first_name, :last_name, :gender, :fb_avatar, :location, :avatar,
                  :birthdate, :phone_number, :zip_code, :city_id, :passions_attributes, :description,
                  :email_opt_in, :sms_opt_in, :email_promo_opt_in, :email_newsletter_opt_in, :email_passions_opt_in

  accepts_nested_attributes_for :passions,
                                 reject_if: lambda {|attributes| attributes['subject_id'].blank? },
                                 allow_destroy: true

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  has_attached_file :avatar,
                    styles: { wide: '800x800#', normal: '450x', thumb: '200x200#', small: '100x100#', mini: '40x40#' }#,

  after_create :associate_all_comments
  after_create :associate_city_from_zip_code, if: -> { zip_code.present? }

  # Scopes
  scope :active,   -> { where{encrypted_password != nil} }
  scope :inactive, -> { where{encrypted_password == ''} }


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
      user.password           = Devise.friendly_token[0,20]

      # Extra
      user.location           = auth.info.location
      user.gender             = auth.extra.raw_info.gender
      user.birthdate          = Date.strptime(auth.extra.raw_info.birthday, '%m/%d/%Y') if auth.extra.raw_info.birthday.present?

      user.save!
    end
  end

  def has_avatar?
    self.avatar.exists? or self.fb_avatar
  end

  def avatar_url(format=:normal)
    if self.avatar.exists?
      self.avatar.url(format)
    elsif self.fb_avatar
      self.fb_avatar
    else
      self.avatar
    end
  end

  # Type in: small square large normal
  def fb_avatar(type='square')
    self.read_attribute(:fb_avatar).split("=")[0] << "=#{type}" unless self.read_attribute(:fb_avatar).nil?
  end

  def reservation_for?(reservable)
    self.reservations.exists?(reservable_id: reservable.id, reservable_type: (reservable.is_a?(Course) ? 'Course' : reservable.class.name))
  end

  def mailboxer_email(object)
    self.email
  end

  def generate_and_set_reset_password_token
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

    self.update_column :reset_password_token,   enc
    self.update_column :reset_password_sent_at, Time.now.utc
    return raw
  end

  def reset_password_token_valid?(token)
    Devise.token_generator.digest(self, :reset_password_token, token) == self.reset_password_token
  end

  def active?
    self.encrypted_password.present?
  end

  def merge user
    # Comments
    self.comments              = user.comments
    # Comments notifications
    self.comment_notifications = user.comment_notifications
    # Mailbox
    user_id = user.id
    Notification.where{(sender_id == user_id) & (sender_type == 'User')}.update_all(sender_id: self.id)
    Receipt.where{(receiver_id == user_id) & (receiver_type == 'User')}.update_all(receiver_id: self.id)
    self.save
    user.reload.destroy
  end

  def name
    self.full_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def name_with_email
    if self.name
      "#{self.name} (#{self.email})"
    else
      self.email
    end
  end

  # Returns the completion percentage of the user
  def profile_completion
    percentage = 0
    percentage += 20 if self.has_avatar?
    percentage += 20 if self.city
    percentage += 20 if self.gender and self.birthdate
    percentage += 20 if self.passions.any?
    percentage += 20 if self.full_name.present?
  end

  def around_courses_url
    structures_path(lat: self.city.latitude, lng: self.city.longitude, subject_slugs: self.passions.map(&:subject).compact.map(&:slug))
  end

  def around_courses_search
    subjects         = self.passions.map(&:subject).compact
    @@course_search ||= CourseSearch.search({lat: self.city.latitude,
                                          lng: self.city.longitude,
                                          radius: 6,
                                          per_page: 1,
                                          subject_slugs: subjects.map(&:slug)
                                      })

  end

  def around_courses_count
    return 0 unless self.city
    around_courses_search.total
  end

  def around_trial_courses_count
    return 0 unless self.city
    around_courses_search.facet(:has_free_trial_lesson).rows.last.count
  end

  private

  def random_string
    (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
  end

  def associate_city_from_zip_code
    _zip_code = self.zip_code
    self.update_column :city_id, City.where{zip_code == _zip_code}.first.try(:id)
  end

  def associate_all_comments
    _email   = self.email
    _user_id = self.id
    Comment.where{email =~ _email}.each do |comment|
      comment.update_column(:user_id, _user_id)
    end
  end
end
