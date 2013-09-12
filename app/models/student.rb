class Student < ActiveRecord::Base
  include ActsAsUnsubscribable
  attr_accessible :email, :city, :email_status, :structure_id, :email_opt_in

  belongs_to :structure

  validates :email, uniqueness: {scope: 'structure_id'}

  validates :email, presence: true
  validates :email, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }


  # after_save :subscribe_to_mailchimp if Rails.env.production?

  def has_recommanded?
    _email        = self.email
    _structure_id = self.structure_id
    Comment.where{(email == _email) & (commentable_id == _structure_id) & (commentable_type == 'Structure')}.length > 0
  end

  def ask_for_feedbacks_stage_1
    if self.email_opt_in
      @structure = self.structure
      @email     = self.email
      self.update_attribute(:email_status, 'resend_stage_1')
      StudentMailer.delay.ask_for_feedbacks_stage_1(self.structure, self.email)
    end
  end

  def ask_for_feedbacks_stage_2
    if self.email_opt_in
      @structure = self.structure
      @email     = self.email
      self.update_attribute(:email_status, 'resend_stage_2')
      StudentMailer.delay.ask_for_feedbacks_stage_2(self.structure, self.email)
    end
  end

  def ask_for_feedbacks_stage_3
    if self.email_opt_in
      @structure = self.structure
      @email     = self.email
      self.update_attribute(:email_status, 'resend_stage_3')
      StudentMailer.delay.ask_for_feedbacks_stage_3(self.structure, self.email)
    end
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
