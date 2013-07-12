class ::Admin < ActiveRecord::Base
  CIVILITY = [
    'civility.male',
    'civility.female'
  ]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable

  after_save :delay_subscribe_to_mailchimp if Rails.env.production?
  before_save :activate_admin

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
                  :password, :password_confirmation, :remember_me,
                  :civility, :name,
                  # :first_name,
                  # :last_name,
                  :phone_number, :mobile_phone_number,
                  :active,                        # Not used
                  :management_software_used,
                  :role,                          # Not used
                  :is_teacher,                    # Not used
                  :structure_id

  validates :password, :email, :structure, presence: true, on: :create

  # attr_accessible :title, :body
  belongs_to :structure, dependent: :destroy

  # Scopes
  scope :normal, where(super_admin: false)

  private
  def activate_admin
    self.active = true
  end

  def delay_subscribe_to_mailchimp
    self.delay.subscribe_to_mailchimp
  end

  def subscribe_to_mailchimp
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_TEACHERS_LIST_ID,
                           :email_address => self.email,
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
