class InvitedUser < ActiveRecord::Base

  belongs_to :referrer

  validates :email, uniqueness: { scope: 'referrer_id' }

  attr_accessible :type, :email

  def inform_proposer
    self.update_column :registered, true
    InvitedUserMailer.delay.inform_invitation_success(self.structure, self.email)
  end

  def send_invitation_stage_1
    @structure = self.structure
    @email     = self.email
    self.email_status =  'resend_stage_1'
    self.save
    InvitedUserMailer.delay.send_invitation_stage_1(self.structure, self.email)
  end

  def send_invitation_stage_2
    @structure = self.structure
    @email     = self.email
    self.email_status =  'resend_stage_2'
    self.save
    InvitedUserMailer.delay.send_invitation_stage_2(self.structure, self.email)
  end

  def referrer
    self.referrer_type.constantize.find(self.referrer_id)
  end

end
