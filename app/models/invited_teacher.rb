class InvitedTeacher < ActiveRecord::Base

  attr_accessible :email, :structure

  belongs_to :structure

  validates :email, uniqueness: {scope: 'structure_id'}

  def registered?
    Admin.where(email: self.email).count > 0
  end
end
