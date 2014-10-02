class User < ActiveRecord::Base

  include Concerns::HstoreHelper
  include Concerns::HasDeliveryStatus
  include Concerns::MessagableWithLabel
  include ActsAsUnsubscribable
  include Rails.application.routes.url_helpers

  acts_as_messageable

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :confirmable,
         :omniauth_providers => [:facebook]


  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :oauth_token, :oauth_expires_at,
                  :name, :first_name, :last_name, :gender, :fb_avatar, :location, :avatar,
                  :birthdate, :phone_number, :zip_code, :city_id, :passion_zip_code, :passion_city_id, :passions_attributes, :description,
                  :email_opt_in, :sms_opt_in, :email_promo_opt_in, :email_newsletter_opt_in, :email_passions_opt_in,
                  :email_status, :last_email_sent_at, :last_email_sent_status,
                  :lived_places_attributes, :delivery_email_status

  # To store hashes into hstore
  store_accessor :meta_data, :after_sign_up_url, :have_seen_first_jpo_popup

  define_boolean_accessor_for :meta_data, :have_seen_first_jpo_popup


  has_attached_file :avatar,
                    styles: { wide: '800x800#', normal: '450x', thumb: '200x200#', small: '100x100#', mini: '40x40#' }

  validates_attachment_content_type :avatar, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_many :comments, -> { order('created_at DESC') }, class_name: 'Comment::Review'
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
  has_many :followings

  has_many :discovery_passes
  has_many :participation_requests

  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :invited_participations, class_name: 'Participation'

  belongs_to :city
  belongs_to :passion_city, class_name: 'City'

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
  after_save   :subscribe_to_mailchimp

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
  scope :with_avatar, -> { where.not(avatar_file_name: nil) }


  searchable do
    text :first_name
    text :last_name
    text :full_name
    text :email

    string :email
    boolean :active do
      self.active?
    end

    # Here we store event the subject at depth 2 for pro admin dashboard purpose.
    integer :subject_ids, multiple: true do
      subject_ids = []
      self.subjects.uniq.each do |subject|
        subject_ids << subject.id
        subject_ids << subject.parent.id if subject.parent
        subject_ids << subject.root.id if subject.root
      end
      subject_ids.compact.uniq
    end

    boolean :has_comments do
      comments.any?
    end

    boolean :has_confirmed do
      confirmed?
    end
    time :created_at

  end

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
      user.provider           = auth.provider
      user.uid                = auth.uid
      user.oauth_token        = auth.credentials.token
      user.oauth_expires_at   = Time.at(auth.credentials.expires_at)

      user.first_name         = auth.info.first_name        if user.first_name.nil?
      user.last_name          = auth.info.last_name         if user.last_name.nil?
      user.email              = auth.info.email             if user.email.nil?
      user.fb_avatar          = auth.info.image             if user.fb_avatar.nil?
      user.password           = Devise.friendly_token[0,20] if user.password.nil?

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
    if type == 'large'
      self.read_attribute(:fb_avatar).gsub(/^http:/, 'https:').split("?")[0] << "?width=200&height=200" unless self.read_attribute(:fb_avatar).nil?
    else
      self.read_attribute(:fb_avatar).gsub(/^http:/, 'https:').split("=")[0] << "=#{type}" unless self.read_attribute(:fb_avatar).nil?
    end
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

    Mailboxer::Notification.where(Mailboxer::Notification.arel_table[:sender_id].eq(user_id).and(
                                  Mailboxer::Notification.arel_table[:sender_type].eq('User'))
                                ).update_all(sender_id: self.id)
    Mailboxer::Receipt.where(Mailboxer::Receipt.arel_table[:receiver_id].eq(user_id).and(
                             Mailboxer::Receipt.arel_table[:receiver_type].eq('User'))
                            ).update_all(receiver_id: self.id)
    self.save
    user.reload.destroy
  end

  def name
    self.full_name
  end

  def full_name
    "#{first_name.try(:capitalize)} #{last_name.try(:upcase)}"
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
    percentage += 20 if self.has_avatar? and self.city
    percentage += 20 if self.passions.any?
    percentage += 20 if self.followings.any?
    percentage
  end

  # Params for structures_path regarding the data we have on the user
  #
  # @return Hash
  def around_courses_params
    if self.city
      if self.passions.any?
        { lat: self.city.latitude, lng: self.city.longitude, subject_slugs: self.passions.map(&:subjects).compact.flatten.map(&:slug) }
      else
        { lat: self.city.latitude, lng: self.city.longitude }
      end
    else
      {}
    end
  end

  # A url to the /structures page of courses that correspond to user's passion
  #
  # @return string the url
  def around_courses_url
    structures_path(around_courses_params)
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

  # Method called when a user confirm his registration
  #
  # @return nil
  def confirm!
    super
    check_if_was_invited
    send_welcome_email
    nil
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
    self.participations.not_canceled.length < 6
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

  def send_jpo_recap(participation = nil)
    ParticipationMailer.delay.recap(self)
    if participation
      invited_friends = participation.invited_friends.uniq
    else
      invited_friends = self.participations.map(&:invited_friends).flatten.uniq
    end
    invited_friends.map{ |invited_friend| ParticipationMailer.delay.recap_from_friend(invited_friend, self)}
  end

  def follows?(structure)
    self.followings.map(&:structure_id).include? structure.id
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

  # Give structures around the user not filtered on subjects
  # @param limit=3   Integer # of structures that should be returned
  # @param params={} Hash    eventualparams for the search
  #
  # @return Array of Structure
  def around_structures_all_subjects(limit=3, _params={}, radius_start=0)
    @city = city || City.find('paris')

    @structures = [] # The structures we will return at the ed
    (radius_start..7).each do |index|
      @structures << StructureSearch.search({lat: @city.latitude,
                                            lng: @city.longitude,
                                            # Radius will increment from 2.7 to > 1000
                                            radius: Math.exp(index),
                                            sort: 'premium',
                                            has_logo: true,
                                            per_page: limit
                                          }.merge(_params)).results
      @structures = @structures.flatten.uniq
      break if @structures.length >= limit
    end
    return @structures[0..(limit - 1)]
  end


  # Return current (last) discovery_pass
  #
  # @return DiscoveryPass or nil if there is no current DiscoveryPass
  def discovery_pass
    discovery_pass = self.discovery_passes.order('created_at DESC').first
    return discovery_pass
  end

  # Tells if the user is based in Paris and around
  #
  # @return Boolean
  def parisian?
    return self.zip_code.starts_with? '75','77','78','91','92','93','94','95'
  end

  private

  def random_string
    (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
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

  # Tells wether a lived_place should be rejected
  # @param  attributes nested in params
  #
  # @return Boolean
  def lived_place_invalid?(attributes)
    attributes['zip_code'].blank? or attributes['city_id'].blank?
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
    MailchimpUpdater.delay.update(self)
  end

end
