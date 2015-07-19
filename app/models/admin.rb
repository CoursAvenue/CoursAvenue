class ::Admin < ActiveRecord::Base
  acts_as_paranoid
  acts_as_messageable
  include Concerns::HstoreHelper
  include Concerns::MessagableWithLabel
  include Concerns::HasDeliveryStatus
  include ActsAsUnsubscribable

  CIVILITY = [
    'civility.male',
    'civility.female'
  ]

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
                  :password, :password_confirmation, :remember_me,
                  :civility, :name,
                  :phone_number, :mobile_phone_number,
                  :structure_id,
                  :email_opt_in,
                  :student_action_email_opt_in, :newsletter_email_opt_in,
                  :monday_email_opt_in, :stats_email, :delivery_email_status,
                  :sms_opt_in, :structure_attributes

  store_accessor :email_opt_in_status, :student_action_email_opt_in, :newsletter_email_opt_in,
                                       :monday_email_opt_in, :stats_email

  define_boolean_accessor_for :email_opt_in_status, :student_action_email_opt_in, :newsletter_email_opt_in, :monday_email_opt_in,
                              :stats_email

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :structure
  accepts_nested_attributes_for :structure

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :password, :email, :structure, presence: true, on: :create

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :create_in_intercom if Rails.env.production?
  after_create :check_if_was_invited
  after_create :set_email_opt_ins
  after_create :subscribe_to_crm

  before_save    :downcase_email
  before_destroy :delete_from_intercom if Rails.env.production?

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :normal, -> { where(super_admin: false) }

  # ------------------------------------
  # ------------------ Search attributes
  # ------------------------------------
  # :nocov:
  searchable do
    text :name
    text :email
    text :structure_name do
      self.structure.name if self.structure
    end

    integer :comments_count do
      self.structure.comments_count if self.structure
    end

    date :created_at

    boolean :not_confirmed do
      self.confirmed?
    end
    boolean :super_admin
  end
  handle_asynchronously :solr_index, queue: 'index' unless Rails.env.test?
  # :nocov:

  # Override of a Mailboxer method.
  #
  # @return String, the admin email.
  def mailboxer_email(_)
    self.email
  end

  def avatar
    self.structure.logo.url(:thumb)
  end

  def avatar_url(format=:thumb)
    self.structure.logo.url(format)
  end

  def name
    if self.structure
      structure.name
    else
      read_attribute(:name)
    end
  end

  # Create a new Admin from Facebook
  #
  # @param auth      - The data from Facebook
  # @param structure - The admin's structure
  #
  # @return Admin
  def self.from_omniauth(auth, structure)
    admin = Admin.where(provider: auth.provider, uid: auth.uid).first || Admin.where(email: auth.info.email).first
    return nil if admin.nil? and structure.nil?

    if admin.nil?
      admin           = Admin.new
      admin.email     = auth.info.email if auth.info.email.present?
      admin.password  = Devise.friendly_token[0, 20] if admin.password.blank?
      admin.structure = structure
      admin.confirm!
    end
    admin.provider         = auth.provider
    admin.uid              = auth.uid
    admin.oauth_token      = auth.credentials.token
    admin.oauth_expires_at = Time.at(auth.credentials.expires_at)
    admin.save

    admin
  end

  # Check if the current Admin has been created from Facebook.
  #
  # @return Boolean
  def from_facebook?
    self.provider == 'facebook' and self.oauth_token.present?
  end

  # The Facebook pages administrated by the Admin.
  #
  # @return an Array of Array of [ page_name, URL ]
  def facebook_pages
    return [] unless from_facebook? and oauth_expires_at > Time.current
    user = FbGraph::User.me(oauth_token).fetch
    user.accounts.map { |page| [page.name, page.link] }
  end

  private

  def subscribe_to_crm
    CrmSync.delay.update(self.structure) if self.structure and !self.structure.crm_locked?
    structure.lock_crm!
  end

  def check_if_was_invited
    InvitedUser.where(email: self.email).map(&:inform_proposer)
  end

  # Set all email opt_in to true
  #
  # @return nil
  def set_email_opt_ins
    self.student_action_email_opt_in = true
    self.newsletter_email_opt_in     = true
    self.monday_email_opt_in         = true
    self.stats_email                 = true
    self.save(validate: false)
  end

  # Change the email to force it to be downcase
  #
  # @return
  def downcase_email
    self.email = self.email.downcase if self.email
    nil
  end

  def create_in_intercom
    intercom_client = IntercomClientFactory.client
    user = intercom_client.users.create(email:        self.email,
                                        name:         self.structure.name,
                                        signed_up_at: Time.now.to_i,
                                        user_id:      "Admin_#{self.id}")
    user.custom_attributes['Villes']                = structure.places.map(&:city).map(&:name).join(', ')
    user.custom_attributes['A confirmé son compte'] = false
    user.custom_attributes['Disciplines_1']         = structure.subjects.at_depth(0).uniq.map(&:name).join(', ')
    user.custom_attributes['Disciplines_2']         = structure.subjects.at_depth(2).map(&:parent).uniq.map(&:name).join(', ')
    user.custom_attributes['Disciplines_3']         = structure.subjects.at_depth(2).uniq.map(&:name).join(', ')
    user.custom_attributes['Prof tag']              = CrmSync.structure_status_for_intercom(structure)
    user.custom_attributes['Code postal']           = structure.zip_code
    intercom_client.users.save(user)
  end
  handle_asynchronously :create_in_intercom

  def delete_from_intercom
    begin
      intercom_client = IntercomClientFactory.client
      intercom_client.users.find(user_id: "Admin_#{self.id}").delete
    rescue
    end
  end
end
