class ::Admin < ActiveRecord::Base
  acts_as_paranoid

  acts_as_messageable

  include ActsAsUnsubscribable

  CIVILITY = [
    'civility.male',
    'civility.female'
  ]

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable

  after_create :check_if_was_invited
  after_save :delay_subscribe_to_nutshell
  after_save :delay_subscribe_to_mailchimp

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
                  :password, :password_confirmation, :remember_me,
                  :civility, :name,
                  :phone_number, :mobile_phone_number,
                  :management_software_used,
                  :structure_id,
                  :email_opt_in, # To be removed?
                  :student_action_email_opt_in, :newsletter_email_opt_in, :monday_email_opt_in, :thursday_email_opt_in

  validates :password, :email, :structure, presence: true, on: :create

  belongs_to :structure

  # Scopes
  scope :normal, -> { where(super_admin: false) }

  # ------------------------------------
  # ------------------ Search attributes
  # ------------------------------------
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
  end
  handle_asynchronously :solr_index

  def confirm!
    super
    send_welcome_email
  end

  def send_welcome_email
    AdminMailer.delay.admin_validated(self)
  end

  def mailboxer_email(object)
    self.email
  end

  def avatar
    self.structure.logo(:thumb)
  end

  def avatar_url(format=:thumb)
    self.structure.logo.url(format)
  end

  def name
    if read_attribute(:name).blank? and self.structure
      structure.name
    else
      read_attribute(:name)
    end
  end

  private

  def delay_subscribe_to_nutshell
    self.structure.send(:delay_subscribe_to_nutshell) if self.structure and Rails.env.production?
  end
  handle_asynchronously :delay_subscribe_to_nutshell, :run_at => Proc.new { 20.minutes.from_now }

  def delay_subscribe_to_mailchimp
    self.structure.send(:delay_subscribe_to_mailchimp) if self.structure and Rails.env.production?
  end

  def check_if_was_invited
    InvitedUser.where(email: self.email).map(&:inform_proposer)
  end

end
