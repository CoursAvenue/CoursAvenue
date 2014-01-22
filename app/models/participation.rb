class Participation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
  belongs_to :planning

  has_one :structure, through: :planning
  has_one :course, through: :planning

  attr_accessible :user, :planning

  default_scope -> { order('created_at ASC') }

  def alert_for_destroy
    ParticipationMailer.delay.alert_for_destroy(self)
  end

  def alert_for_changes
    ParticipationMailer.delay.alert_for_changes(self)
  end

end
