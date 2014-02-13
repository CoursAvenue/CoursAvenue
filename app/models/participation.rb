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
  # Validation                                                         #
  ######################################################################
  validate :first_participation_to_jpo, on: :create

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :welcome_email
  after_create :user_subscribed_email_for_teacher

  before_save  :set_waiting_list
  before_save  :update_structure_meta_datas

  after_destroy :update_planning_participations_waiting_list
  after_destroy :unsubscription_email
  after_destroy :unsubscription_email_for_teacher

  attr_accessible :user, :planning

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  default_scope               -> { order('created_at ASC') }
  scope :waiting_list       , -> { where { waiting_list == true } }
  scope :not_in_waiting_list, -> { where { waiting_list == false } }

  ######################################################################
  # Email alerts                                                       #
  ######################################################################
  # Email sent to the teacher when a user registers to a JPO
  #
  # @return nil
  def user_subscribed_email_for_teacher
    if waiting_list
      ParticipationMailer.delay.user_subscribed_to_waiting_list(self)
    else
      ParticipationMailer.delay.user_subscribed(self)
    end
    nil
  end

  # Email sent to the user when registrating to a JPO
  #
  # @return nil
  def welcome_email
    if waiting_list
      ParticipationMailer.delay.welcome_to_waiting_list(self)
    else
      ParticipationMailer.delay.welcome(self)
    end
    nil
  end


  # Email to confirm unsubscription
  #
  # @return nil
  def unsubscription_email
    ParticipationMailer.delay.unsubscription(self)
    nil
  end

  # Email to inform the teacher of the unsubscription
  #
  # @return nil
  def unsubscription_email_for_teacher
    ParticipationMailer.delay.unsubscription_for_teacher(self)
    nil
  end

  def alert_for_changes
    ParticipationMailer.delay.alert_for_changes(self)
  end

  def alert_for_destroy
    ParticipationMailer.delay.alert_for_destroy(self)
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

  # Only one participation is allowed per user for JPO courses
  #
  # @return nil
  def first_participation_to_jpo
    unless user.participations.empty?
      self.errors[:base] << I18n.t('participations.errors.only_one_participation_for_jpo')
    end
    nil
  end

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

  #
  # Update structure meta datas when participation change to update the number of "Places left"
  #
  # @return nil
  def update_structure_meta_datas
    planning.structure.update_meta_datas
    nil
  end
end
