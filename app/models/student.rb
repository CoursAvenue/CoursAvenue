class Student < ActiveRecord::Base
  attr_accessible :email, :city, :email_status, :structure_id

  belongs_to :structure

  validates :email, uniqueness: {scope: 'structure_id'}

  validates :email, presence: true
  validates :email, format: { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  def access_token
    Student.create_access_token(self)
  end

  # Verifier based on our application secret
  def self.verifier
    ActiveSupport::MessageVerifier.new(CoursAvenue::Application.config.secret_token)
  end

  # Get a student from a token
  def self.read_access_token(signature)
    id = verifier.verify(signature)
    Student.find id
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  # Class method for token generation
  def self.create_access_token(student)
    verifier.generate(student.id)
  end

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
