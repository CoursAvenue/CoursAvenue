class User < ActiveRecord::Base

  include Concerns::HstoreHelper
  include Concerns::HasDeliveryStatus
  include Concerns::MessagableWithLabel
  include Concerns::SMSSender
  include Concerns::ReminderEmailStatus
  include ActsAsUnsubscribable
  include Concerns::HasRandomToken
  include Rails.application.routes.url_helpers

  acts_as_messageable
  acts_as_paranoid

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :oauth_token, :oauth_expires_at,
                  :name, :first_name, :last_name, :gender, :fb_avatar, :location,
                  :avatar, :remote_avatar_url,
                  :birthdate, :phone_number, :zip_code, :city_id, :description,
                  :email_opt_in, :sms_opt_in, :email_promo_opt_in, :email_newsletter_opt_in,
                  :email_status, :last_email_sent_at, :last_email_sent_status,
                  :delivery_email_status, :sign_up_at,
                  :test_name, :interested_at, :token,
                  :subscription_from, :community_notification_opt_in

  # To store hashes into hstore
  store_accessor :meta_data, :after_sign_up_url,
                             :test_name, :interested_at, :subscription_from

  define_boolean_accessor_for :meta_data

  mount_uploader :avatar, UserAvatarUploader

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_many :comments, -> { order('created_at DESC') }, class_name: 'Comment::Review'
  has_many :comment_notifications
  has_many :invited_users, foreign_key: :referrer_id, dependent: :destroy
  has_many :user_profiles
  has_many :structures, through: :user_profiles

  has_many :favorites, class_name: 'User::Favorite', dependent: :destroy

  has_many :participation_requests

  # I have sponsored many users
  has_many :sponsorships
  # Other users had sponsored me
  has_many :sponsors, class_name: 'Sponsorship', foreign_key: 'sponsored_user_id'

  has_many :community_memberships, class_name: 'Community::Membership', dependent: :destroy
  has_many :communities, through: :community_memberships

  has_and_belongs_to_many :subjects

  belongs_to :city

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :associate_all_comments
  after_save   :subscribe_to_mailchimp if Rails.env.production?

  def self.force_create(params)
    return if params[:email].blank?
    u = User.new(params)
    u.email = u.email.downcase if u.email.present?
    u.valid? # Validate to trigger errors
    # We don't want to save users with fucked up email addresses
    if u.errors[:email].blank? # check if email is valid
      u.save(validate: false)
    end
    u
  end
  # Called from Registration Controller when user registers for first time
  def after_registration
    send_pending_messages
  end

  # Not after create because user creation is made when teachers invite their students to post a comment
  after_save  :associate_city_from_zip_code, if: -> { zip_code.present? and city.nil? }
  after_save  :update_email_status
  before_save :downcase_email

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :first_name, :email, presence: true
  validates :email, uniqueness: true

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :active,   -> { where.not(encrypted_password: '') }
  scope :inactive, -> { where( User.arel_table[:encrypted_password].eq('').or(User.arel_table[:encrypted_password] == nil)) }
  scope :with_avatar, -> { where.not(avatar: nil) }

  # Creates a user from Facebook
  #
  # @param  auth [type] [description]
  #
  # @return User
  def self.from_omniauth(auth)
    # Check if the user already exists
    # TODO: Check if it works
    # ((provider == auth.provider) & (uid == auth.uid)) | (email == auth.info.email)}.first_or_initialize.tap do |user|
    where((User.arel_table[:provider].eq(auth.provider).and(User.arel_table[:uid].eq(auth.uid))).or(User.arel_table[:email].eq(auth.info.email))).first_or_initialize.tap do |user|
      # If the user was not active, set its created at
      if !user.active?
        user.sign_up_at = Time.now
      end

      user.provider           = auth.provider
      user.uid                = auth.uid
      user.oauth_token        = auth.credentials.token
      user.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      user.first_name         = auth.info.first_name        if user.first_name.blank?
      user.last_name          = auth.info.last_name         if user.last_name.blank?
      user.email              = auth.info.email             if user.email.blank?
      user.fb_avatar          = auth.info.image             if user.fb_avatar.blank?
      user.password           = Devise.friendly_token[0,20] if user.password.blank?

      if user.city.nil? and auth.info.location
        city = City.where(City.arel_table[:name].matches(auth.info.location.split(',').first)).first
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

  def self.create_or_find_from_email(_email, first_name='')
    user = User.where(email: _email).first_or_initialize
    user.first_name ||= first_name
    user.save(validate: false) unless user.persisted?
    user
  end

  # Sends a reminder of classes on the following day.
  #
  # @return a Boolean, whether the sms was sent or not.
  def send_sms_reminder
    if phone_number and sms_opt_in?
      _participation_requests = participation_requests.where(date: Date.tomorrow, state: 'accepted')
      return false if _participation_requests.empty?

      if _participation_requests.length > 1
        message = I18n.t('sms.users.day_before_reminder.multiple_course',
                         _participation_requests: _participation_requests.length,
                         start_time: I18n.l(_participation_requests.first.start_time, format: :short))
      else
        message = _participation_requests.first.decorate.sms_reminder_message
      end

      self.delay.send_sms(message, phone_number)
    end
  end

  # Update the email status regarding info completion
  def update_email_status
    email_status = nil
    self.update_column :email_status, email_status
    return email_status
  end

  # Check if the user has a avatar.
  # We check if the avatar has a URL because the uploader always creates the
  # avatar object.
  #
  # @return Boolean
  def has_avatar?
    avatar.present? or read_attribute(:fb_avatar)
  end

  def avatar_url(format = :normal)
    if avatar.present?
      self.avatar.url(format)
    elsif read_attribute(:fb_avatar)
      self.fb_avatar(format)
    else
      self.avatar.url(format) # To provide default image
    end
  end

  # Type in: small square large normal
  def fb_avatar(format=:normal)
    if format == :normal
      self.read_attribute(:fb_avatar).gsub(/^http:/, 'https:').split("?")[0] << "?width=200&height=200" unless self.read_attribute(:fb_avatar).nil?
    elsif :thumb
      self.read_attribute(:fb_avatar).gsub(/^http:/, 'https:').split("?")[0] << "?width=50&height=50" unless self.read_attribute(:fb_avatar).nil?
    elsif :small_thumb
      self.read_attribute(:fb_avatar).gsub(/^http:/, 'https:').split("?")[0] << "?width=30&height=30" unless self.read_attribute(:fb_avatar).nil?
    else
      self.read_attribute(:fb_avatar).gsub(/^http:/, 'https:').split("?")[0] << "?width=100&height=100" unless self.read_attribute(:fb_avatar).nil?
    end
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

    Mailboxer::Notification.where(Mailboxer::Notification.arel_table[:sender_id].eq(user_id).and(
                                  Mailboxer::Notification.arel_table[:sender_type].eq('User'))
                                ).update_all(sender_id: self.id)
    Mailboxer::Receipt.where(Mailboxer::Receipt.arel_table[:receiver_id].eq(user_id).and(
                             Mailboxer::Receipt.arel_table[:receiver_type].eq('User'))
                            ).update_all(receiver_id: self.id)
    self.save
    user.reload.destroy
  end

  def public_name
    if first_name.present? or last_name.present?
      last_name.present? ? ("#{first_name} #{last_name[0]}.".strip) : first_name
    else
      generated_fake_name
    end
  end

  def name
    if full_name.present?
      full_name
    else
      generated_fake_name
    end
  end

  def full_name
    "#{first_name} #{last_name}".strip
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
    percentage += 25 if self.full_name.present?
    percentage += 25 if self.has_avatar? and self.city
    percentage += 25 if self.subjects.any?
    percentage += 25 if self.favorites.any?
    percentage
  end

  def send_welcome_email
    UserMailer.delay.welcome(self)
  end

  # Get the user profile associated to the given structure
  #
  # @return UserProfile
  def user_profile_for(structure)
    user_profile = self.user_profiles.where(structure_id: structure.id).first
    if user_profile.nil?
      user_profile = structure.user_profiles.create(email: self.email)
    end
    user_profile
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

  @@roots_subjects = ["Culture, Sciences & Nature", "Business & Informatique", "Cuisine & Vins", "Musique & Chant", "Photo & Vidéo", "Déco, Mode & Bricolage", "Langues & Soutien scolaire", "Yoga, Bien-être & Santé", "Sports", "Danse", "Dessin, Peinture & Arts", "Théâtre & Scène"]
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

  def follows?(structure)
    self.favorites.pluck(:structure_id).include?(structure.id)
  end

  def city
    if read_attribute(:city_id)
      City.find(read_attribute(:city_id))
    elsif structures.any?
      cities = structures.map(&:city) + structures.map(&:places).flatten.map(&:city)
      cities.group_by{ |city| city }.values.max_by(&:size).first
    else
      nil
    end
  end

  # Tells if the user is based in Paris and around
  #
  # @return Boolean
  def parisian?
    return self.zip_code.starts_with? '75','77','78','91','92','93','94','95'
  end

  # Tells wether the user left a review on a specific Structure
  # @param structure
  #
  # @return Boolean
  def has_left_a_review_on?(structure)
    self.comments.where(commentable_id: structure.id, commentable_type: 'Structure').any?
  end

  def age
    if self.birthdate
      age = Date.today.year - self.birthdate.year
      age -= 1 if Date.today < self.birthdate + age.years # for days before birthdate
      age
    end
  end

  def token
    if read_attribute(:token).present?
      read_attribute(:token)
    else
      create_token
      save(validate: false)
      read_attribute(:token)
    end
  end

  # @return Subject at depth 2
  def dominant_subject
    if participation_requests.any? and (_subjects = participation_requests.map(&:course).flat_map(&:subjects)).any?
      return _subjects.group_by{ |subject| subject.root }.values.max_by(&:size).first.root
    elsif structures.any?
      return structures.first.dominant_root_subject
    end
  end

  private

  def generated_fake_name
    email.split('@').first
  end

  # Update city id of the user regarding the zip_code he choosed when registering
  #
  # @return nil
  def associate_city_from_zip_code
    _zip_code = self.zip_code
    self.update_column :city_id, City.where(zip_code: _zip_code).first.try(:id)
    nil
  end

  def associate_all_comments
    _email   = self.email
    _user_id = self.id
    Comment::Review.where(Comment::Review.arel_table[:email].matches(_email)).each do |comment|
      comment.update_column(:user_id, _user_id)
    end
  end

  def check_if_was_invited
    InvitedUser.where(type: 'InvitedUser::Student', email: self.email).map(&:inform_proposer)
  end

  # Change the email to force it to be downcase
  #
  # @return
  def downcase_email
    self.email = self.email.downcase if self.email
    nil
  end

  # Send messages that have been created with this user (aka email) and inform
  # the teacher about it.
  #
  # @return nil
  def send_pending_messages
    self.mailbox.conversations.where(mailboxer_label_id: Mailboxer::Label::INFORMATION.id).each do |conversation|
      # Get the message that should have been sent
      message = conversation.messages.first
      # Select the admin who should receive the message
      recipient = message.recipients.detect{ |recipient| recipient.is_a? Admin }
      MailboxerMessageMailer.delay.new_message_email_to_admin(message, recipient)
    end
    nil
  end

  def subscribe_to_mailchimp
    MailchimpUpdater.delay.update_user(self)
  end
end
