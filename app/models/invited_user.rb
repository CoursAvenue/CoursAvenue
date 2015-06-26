class InvitedUser < ActiveRecord::Base

  ######################################################################
  # Relations                                                          #
  ######################################################################
  # Person that sends the invite
  belongs_to :referrer

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :email, uniqueness: { scope: 'referrer_id' }

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_save :downcase_email

  ## Type: Student, Structure
  attr_accessible :type, :email, :referrer_id, :referrer_type, :invitation_for
  # To store hashes into hstore
  store_accessor :meta_data, :structure_id

  validates :type, presence: true

  def inform_proposer
    self.registered = true
    self.save
    InvitedUserMailer.delay.inform_invitation_success(self)
  end

  def send_invitation_stage_1
    return unless self.referrer.email_opt_in
    self.email_status =  'resend_stage_1'
    self.save
    InvitedUserMailer.delay.send_invitation_stage_1(self)
  end

  def send_invitation_stage_2
    self.email_status =  'resend_stage_2'
    self.save
    InvitedUserMailer.delay.send_invitation_stage_2(self)
  end

  def referrer
    self.referrer_type.constantize.find(self.referrer_id)
  end

  # Tells if user is opt_in
  #
  # @return Boolean
  def email_opt_in?
    false
  end

  def structure
    if structure_id
      Structure.friendly.find(structure_id)
    elsif referrer_type == 'Structure'
      referrer
    end
  end

  # Return nil
  # Child class should implement this method
  #
  # @return nil
  def user
    nil
  end

  private

  # Change the email to force it to be downcase
  #
  # @return
  def downcase_email
    self.email = self.email.downcase
    nil
  end
end
