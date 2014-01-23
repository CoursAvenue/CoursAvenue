class InvitedUser < ActiveRecord::Base

  belongs_to :referrer

  validates :email, uniqueness: { scope: 'referrer_id' }

  attr_accessible :type, :email, :referrer_id, :referrer_type

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

end
