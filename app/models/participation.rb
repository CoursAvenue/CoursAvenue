class Participation < ActiveRecord::Base
  acts_as_paranoid

  PARTICIPATION_FOR = ['participations.for.one_adult',
                      'participations.for.one_kid',
                      'participations.for.one_kid_and_one_adult' ]

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
  validate  :first_participation_to_jpo, on: :create
  validates :user, presence: true
  validates :planning, presence: true

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :welcome_email
  after_create :user_subscribed_email_for_teacher

  before_save  :set_default_participation_for

  after_save   :update_jpo_meta_datas
  after_save   :index_planning

  before_save  :set_waiting_list
  before_save  :update_structure_meta_datas

  attr_accessible :user, :planning, :participation_for

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  default_scope               -> { order('created_at ASC') }
  scope :waiting_list       , -> { where { waiting_list == true } }
  scope :not_in_waiting_list, -> { where { waiting_list == false } }
  scope :canceled           , -> { where { canceled_at != nil } }
  scope :not_canceled       , -> { where { canceled_at == nil } }

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

  # Tells if the participations is canceled or not
  #
  # @return Boolean [description]
  def canceled?
    !canceled_at.nil?
  end

  # Cancel the participation
  #
  # @return Boolean wether it has saved or not
  def cancel!
    self.canceled_at = Time.now
    if self.save
      update_planning_participations_waiting_list
      unsubscription_email
      unsubscription_email_for_teacher
      return true
    else
      return false
    end
  end

  # Tells if the parent comes with his kid in case of plannings for kids
  # and adults
  #
  # @return Boolean
  def with_kid?
    participation_for == 'participations.for.one_kid_and_one_adult'
  end

  # Return the size of the participation. Does it count for 1 person or 2 ?
  #
  # @return Integer
  def size
    (with_kid? ? 2 : 1)
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
    ParticipationMailer.delay.a_place_opened(self) if waiting_list_changed? and waiting_list == false
    nil
  end

  def set_waiting_list!
    set_waiting_list
    save if waiting_list_changed?
  end

  def alert_for_changes
    ParticipationMailer.delay.alert_for_changes(self)
  end

  def alert_for_destroy
    ParticipationMailer.delay.alert_for_destroy(self)
  end

  private

  # Set default value for `participation_for` attribute
  #
  # return participation_for
  def set_default_participation_for
    self.participation_for ||= 'participations.for.one_adult'
  end

  # Update meta datas related to JPOs on the associated structure
  #
  # @return nil
  def update_jpo_meta_datas
    self.structure.update_jpo_meta_datas
    nil
  end

  # Update index related planning
  #
  # @return nil
  def index_planning
    self.planning.index
  end

  # Only one participation is allowed per user for JPO courses
  #
  # @return nil
  def first_participation_to_jpo
    unless user.participations.not_canceled.empty?
      self.errors[:base] << I18n.t('participations.errors.only_one_participation_for_jpo')
    end
    nil
  end

  # When participation is canceled, update waiting list of all participations of same planning
  #
  # @return nil
  def update_planning_participations_waiting_list
    planning.participations.not_canceled.each do |participation|
      participation.set_waiting_list!
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
