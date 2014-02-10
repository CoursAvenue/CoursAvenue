class Participation < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :user
  belongs_to :planning

  has_one :structure, through: :planning
  has_one :course   , through: :planning

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_save :set_waiting_list
  after_destroy :update_planning_participations_waiting_list

  attr_accessible :user, :planning

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  default_scope               -> { order('created_at ASC') }
  scope :waiting_list       , -> { where { waiting_list == true } }
  scope :not_in_waiting_list, -> { where { waiting_list == false } }

  def alert_for_destroy
    ParticipationMailer.delay.alert_for_destroy(self)
  end

  def alert_for_changes
    ParticipationMailer.delay.alert_for_changes(self)
  end

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  # Set waiting list to true regarding the number of participants and the
  # /!\ Don't make it private
  #
  # @return nil
  def set_waiting_list
    self.waiting_list = ( self.planning.nb_place_available <= 0 )
    nil
  end

  private

  # When participation is destroyed, update waiting list of all participations of same planning
  #
  # @return nil
  def update_planning_participations_waiting_list
    planning.participations.each do |participation|
      participation.set_waiting_list
      participation.save if participation.waiting_list_changed?
    end
    nil
  end
end
