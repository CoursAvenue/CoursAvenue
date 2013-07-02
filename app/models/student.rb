class Student < ActiveRecord::Base
  attr_accessible :email, :city, :email_status, :structure_id

  belongs_to :structure

  validates :email, uniqueness: {scope: 'structure_id'}

  validates :email, presence: true
  validates :email, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  # after_save :subscribe_to_mailchimp if Rails.env.production?

  def ask_for_feedbacks_stage_1
    @structure = self.structure
    @email     = self.email
    self.update_attribute(:email_status, 'resend_stage_1')
    StudentMailer.delay.ask_for_feedbacks_stage_1(self.structure, self.email)
  end

  def ask_for_feedbacks_stage_2
    @structure = self.structure
    @email     = self.email
    self.update_attribute(:email_status, 'resend_stage_2')
    StudentMailer.delay.ask_for_feedbacks_stage_2(self.structure, self.email)
  end

  def ask_for_feedbacks_stage_3
    @structure = self.structure
    @email     = self.email
    self.update_attribute(:email_status, 'resend_stage_3')
    StudentMailer.delay.ask_for_feedbacks_stage_3(self.structure, self.email)
  end

  private
  def subscribe_to_mailchimp
    merge_vars = {
      :STATUS     => 'not registered',
      :NB_COMMENT => 0
    }
    if self.structure
      merge_vars[:STRUC_SLUG] = self.structure.slug
      merge_vars[:STRUC_NAME] = self.structure.name
    end
    Gibbon.list_subscribe({:id => CoursAvenue::Application::MAILCHIMP_USERS_LIST_ID,
                           :email_address => self.email,
                           :merge_vars => merge_vars,
                           :double_optin => false,
                           :update_existing => true,
                           :send_welcome => false}
                           )
  end
end
