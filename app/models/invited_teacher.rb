class InvitedTeacher < ActiveRecord::Base

  attr_accessible :email, :structure

  belongs_to :structure

  validates :email, uniqueness: {scope: 'structure_id'}

  def registered?
    Admin.where(email: self.email).count > 0
  end

  def inform_proposer
    AdminMailer.delay.inform_invitation_success(self.structure, self.email)
  end

end
