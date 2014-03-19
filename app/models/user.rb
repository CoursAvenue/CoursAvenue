class User < ActiveRecord::Base
  extend HstoreHelper

  include ActsAsUnsubscribable
  include Rails.application.routes.url_helpers

  acts_as_messageable

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :oauth_token, :oauth_expires_at,
                  :name, :first_name, :last_name, :gender, :fb_avatar, :location, :avatar,
                  :birthdate, :phone_number, :zip_code, :city_id, :passions_attributes, :description,
                  :email_opt_in, :sms_opt_in, :email_promo_opt_in, :email_newsletter_opt_in, :email_passions_opt_in,
                  :email_status, :last_email_sent_at, :last_email_sent_status,
                  :lived_places_attributes

  # To store hashes into hstore
  store_accessor :meta_data, :after_sign_up_url, :have_seen_first_jpo_popup

  define_boolean_accessor_for :meta_data, :have_seen_first_jpo_popup

  has_attached_file :avatar,
                    styles: { wide: '800x800#', normal: '450x', thumb: '200x200#', small: '100x100#', mini: '40x40#' }#,

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_many :comments, -> { order('created_at DESC') }
  has_many :reservations
  has_many :comment_notifications
  has_many :passions
  has_many :invited_users, foreign_key: :referrer_id, dependent: :destroy
  has_many :user_profiles
  has_many :structures, through: :user_profiles
  has_many :participations
  has_many :plannings, through: :participations

  has_many :lived_places
  has_many :cities, through: :lived_places

  has_and_belongs_to_many :subjects

  belongs_to :city

  accepts_nested_attributes_for :passions,
                                 reject_if: lambda {|attributes| attributes['subject_id'].blank? },
                                 allow_destroy: true

  accepts_nested_attributes_for :lived_places,
                                 reject_if: :lived_place_invalid?,
                                 allow_destroy: true

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :associate_all_comments
  after_create :check_if_was_invited

  # Not after create because user creation is made when teachers invite their students to post a comment
  after_save :associate_city_from_zip_code, if: -> { zip_code.present? and city.nil? }
  after_save :update_email_status

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :active,   -> { where{encrypted_password != ''} }
  scope :inactive, -> { where{(encrypted_password == '') | encrypted_password == nil} }

  # Creates a user from Facebook
  #
  # @param  auth [type] [description]
  #
  # @return [type] [description]
  def self.from_omniauth(auth)
    # Check if the user already exists
    where{((provider == auth.provider) & (uid == auth.uid)) | (email == auth.info.email)}.first_or_initialize.tap do |user|
      user.provider           = auth.provider
      user.uid                = auth.uid
      user.oauth_token        = auth.credentials.token
      user.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      user.first_name         = auth.info.first_name
      user.last_name          = auth.info.last_name
      user.email              = auth.info.email
      user.fb_avatar          = auth.info.image
      user.password           = Devise.friendly_token[0,20]

      if auth.info.location
        city = City.where{ name =~ auth.info.location.split(',').first }.first
        if city
          user.city     = city
          user.zip_code = city.zip_code
        end
      end

      # Extra
      user.location           = auth.info.location
      user.gender             = auth.extra.raw_info.gender
      user.birthdate          = Date.strptime(auth.extra.raw_info.birthday, '%m/%d/%Y') if auth.extra.raw_info.birthday.present?

      user.confirmed_at         = Time.now
      user.confirmation_sent_at = Time.now

      user.save
    end
  end

  ######################################################################
  # Email reminder                                                     #
  ######################################################################

  # Sends reminder depending on the email status of the user
  # This method is called every week through user_reminder rake task
  # (Executed on Heroku by the scheduler)
  #
  # @return nil
  def send_reminder
    if self.email_status and self.email_passions_opt_in?
      if self.update_email_status.present?
        self.update_column :last_email_sent_at, Time.now
        self.update_column :last_email_sent_status, self.email_status
        UserMailer.delay.send(self.email_status.to_sym, self)
      end
    end
  end

  # Update the email status regarding info completion
  def update_email_status
    email_status = nil
    if participations.empty?
      email_status = 'monday_jpo'
      # elsif self.passions.empty?
      #   email_status = 'passions_incomplete'
    end
    self.update_column :email_status, email_status
    return email_status
  end

  def has_avatar?
    self.avatar.exists? or self.fb_avatar
  end

  def avatar_url(format=:normal)
    if self.avatar.exists?
      self.avatar.url(format)
    elsif self.fb_avatar
      if format == :thumb
        self.fb_avatar('large')
      else
        self.fb_avatar
      end
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

  # Check if the user has created an account or not.
  #
  # @return Boolean
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
    percentage += 20 if self.full_name.present?
    percentage += 20 if self.has_avatar?
    percentage += 20 if self.city
    percentage += 20 if self.gender and self.birthdate
    percentage += 20 if self.passions.any?
    percentage
  end

  # A url to the /structures page of courses that correspond to user's passion
  #
  # @return string the url
  def around_courses_url
    if self.city
      if self.passions.any?
        structures_path(lat: self.city.latitude, lng: self.city.longitude, subject_slugs: self.passions.map(&:subjects).compact.flatten.map(&:slug))
      else
        structures_path(lat: self.city.latitude, lng: self.city.longitude)
      end
    else
      structures_path
    end
  end

  def around_courses_search
    subject_array    = self.passions.map(&:subjects).compact.flatten
    @course_search ||= CourseSearch.search({lat: self.city.latitude,
                                          lng: self.city.longitude,
                                          radius: 6,
                                          per_page: 1,
                                          subject_slugs: subject_array.map(&:slug)
                                      })

  end

  def around_courses_count
    return 0 unless self.city
    around_courses_search.total
  end

  def around_trial_courses_count
    return 0 unless self.city
    return 0 if around_courses_search.facet(:has_free_trial_lesson).rows.last.nil?
    around_courses_search.facet(:has_free_trial_lesson).rows.last.count
  end

  def confirm!
    super
    send_welcome_email
  end

  def send_welcome_email
    UserMailer.delay.welcome(self)
  end

  def participate_to?(planning)
    self.participations.not_canceled.map(&:planning).include? planning
  end

  # Tells if the user is allowed to participate
  # He won't be allowed if he has a current participation
  #
  # @return Boolean
  def can_participate_to_jpo_2014?
    self.participations.not_canceled.empty?
  end

  # Get the user profile associated to the given structure
  #
  # @return UserProfile
  def user_profile_for(structure)
    self.user_profiles.where(structure_id: structure.id).first
  end

  def facebook_registered?
    self.oauth_token.present?
  end

  ######################################################################
  # Fox exporting user to csv                                          #
  ######################################################################
  def subjects_for_csv
    roots = []
    if comments.any?
      comments.map do |comment|
        roots += comment.subjects.roots
      end
    end
    if roots.empty?
      structures.map do |structure|
        roots += structure.subjects.roots
      end
    end
    subjects_to_array_for_csv roots.uniq.map(&:name)
  end

  @@roots_subjects = ["Culture, Sciences & Nature", "Business & Informatique", "Cuisine & Vins", "Musique & Chant", "Photo & Vidéo", "Déco, Mode & Bricolage", "Langues & Soutien scolaire", "Yoga, Bien-être & Santé", "Sports & Arts martiaux", "Danse", "Dessin, Peinture & Arts", "Théâtre & Scène"]
  def subjects_to_array_for_csv(user_subjects)
    @@roots_subjects.map do |subject|
      if user_subjects.include?(subject)
        subject
      else
        nil
      end
    end
  end

  def zip_code_for_csv
    structures.map(&:places).flatten.map(&:zip_code).join(', ')
  end

  def self.to_csv
    CSV.generate col_sep: ';' do |csv|
      all.each do |user|
        csv << [user.email] + user.subjects_for_csv + [user.zip_code_for_csv]
      end
    end
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

  def check_if_was_invited
    InvitedUser.where(type: 'InvitedUser::Student', email: self.email).map(&:inform_proposer)
  end

  # Tells wether a lived_place should be rejected
  # @param  attributes nested in params
  #
  # @return Boolean
  def lived_place_invalid?(attributes)
    attributes['zip_code'].blank? or attributes['city_id'].blank?
  end
end
