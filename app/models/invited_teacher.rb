class InvitedTeacher < ActiveRecord::Base

  attr_accessible :email, :structure

  belongs_to :structure

  validates :email, uniqueness: {scope: 'structure_id'}

  def inform_proposer
    self.update_column :registered, true
    AdminMailer.delay.inform_invitation_success(self.structure, self.email)
  end


  def send_invitation_stage_1
    @structure = self.structure
    @email     = self.email
    self.email_status =  'resend_stage_1'
    self.save
    AdminMailer.delay.send_invitation_stage_1(self.structure, self.email)
  end

  def send_invitation_stage_2
    @structure = self.structure
    @email     = self.email
    self.email_status =  'resend_stage_2'
    self.save
    AdminMailer.delay.send_invitation_stage_2(self.structure, self.email)
  end
end
