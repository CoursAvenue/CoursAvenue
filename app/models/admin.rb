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

  after_save :delay_subscribe_to_mailchimp if Rails.env.production?

  after_create :check_if_was_invited

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
                  :password, :password_confirmation, :remember_me,
                  :civility, :name,
                  :email_opt_in,
                  :phone_number, :mobile_phone_number,
                  :management_software_used,
                  :structure_id

  validates :password, :email, :structure, presence: true, on: :create

  belongs_to :structure

  # Scopes
  scope :normal, -> { where(super_admin: false) }

  def confirm!
    super
    send_welcome_email
  end

  def send_welcome_email
    AdminMailer.delay.admin_validated(self)
  end

  private
  def delay_subscribe_to_mailchimp
    self.delay.subscribe_to_mailchimp
  end

  def check_if_was_invited
    InvitedTeacher.where(email: self.email).map(&:inform_proposer)
  end

  def subscribe_to_mailchimp
    gb = Gibbon::API.new
    gb.lists.subscribe({:id => CoursAvenue::Application::MAILCHIMP_TEACHERS_LIST_ID,
                           :email => {email: self.email},
                           :merge_vars => {
                              :NAME => (self.structure ? self.structure.name : ''),
                              :STATUS => 'registered'
                              #:NB_COMMENT
                              #:NB_STUDENT
                              #:NB_PROMO
                              #:NBPLANNING
                           },
                           :double_optin => false,
                           :update_existing => true,
                           :send_welcome => false})
  end
end
