class InvitedUser < ActiveRecord::Base

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :referrer

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :email, uniqueness: { scope: 'referrer_id' }

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :for_jpo, -> { where(for: 'jpo') }

  ## Type: Student, Structure
  attr_accessible :type, :email, :referrer_id, :referrer_type
  # To store hashes into hstore
  store_accessor :meta_data, :structure_id


  def inform_proposer
    self.registered = true
    self.save
    InvitedUserMailer.delay.inform_invitation_success(self)
  end

  def send_invitation_stage_1
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

  def structure
    if structure_id
      Structure.find(structure_id)
    end
  end

end
