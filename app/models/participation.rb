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
  validate  :size_positive, on: :create
  validates :user, presence: true
  validates :planning, presence: true
  validates :nb_kids, numericality: { less_than: 5 }
  validates :nb_adults, numericality: { less_than: 3 }

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :welcome_email
  after_create :user_subscribed_email_for_teacher
  after_create :create_user_profile
  after_create :sends_email_if_no_more_place
  after_create :check_if_was_on_invite

  before_save  :set_default_participation_for
  before_validation  :check_size

  after_save   :update_jpo_meta_datas
  after_save   :index_planning

  before_save  :set_waiting_list, unless: :canceled?
  before_save  :update_structure_meta_datas

  attr_accessible :user, :planning, :participation_for, :nb_adults, :nb_kids

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
      ParticipationMailer.delay.user_subscribed_to_waiting_list(self) if self.structure.main_contact.try(:jpo_email_opt_in)
    else
      ParticipationMailer.delay.user_subscribed(self) if self.structure.main_contact.try(:jpo_email_opt_in)
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
    ParticipationMailer.delay.unsubscription_for_teacher(self) if self.structure.main_contact.try(:jpo_email_opt_in)
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
      Participation.update_planning_participations_waiting_list(planning)
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
    participation_for == 'participations.for.one_kid_and_one_adult' or participation_for == 'participations.for.one_kid'
  end

  # Return the size of the participation. Does it count for 1 person or 2 ?
  #
  # @return Integer
  def size
    # (with_kid? ? 2 : 1)
    nb_adults + nb_kids
  end

  # Set waiting list to true regarding the number of participants and the
  #
  # @return nil
  def set_waiting_list
    self.waiting_list = (self.planning.places_left <= 0 or self.size > planning.places_left)
    nil
  end

  #
  # Call set_waiting_list and saves
  #
  # @return Boolean wether it saved or not
  def set_waiting_list!
    set_waiting_list
    if waiting_list_changed?
      save
    else
      false
    end
  end

  private

  ######################################################################
  # Callbacks                                                          #
  ######################################################################

  # Sets nb_adults to 0 if only for kids
  #
  # @return nil
  def check_size
    if participation_for == 'participations.for.one_kid'
      nb_adults = 0
    end
    nil
  end

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

  # Check if nb_kids and adults are correctly filled
  #
  # @return nil
  def size_positive
    if size == 0
      self.errors[:base] << I18n.t('participations.errors.size_is_nil')
    end
    nil
  end

  # When participation is canceled, update waiting list of all participations of same planning
  # Sends an email to the user if it goes from waiting list to participant
  # @param  planning Planning planning where we have to update the participants
  #
  # @return nil
  def self.update_planning_participations_waiting_list(planning)
    # Sends an email to the user and to the teacher
    places_left = planning.places_left
    planning.participations.not_canceled.waiting_list.order('created_at DESC').each do |participation|
      # Updates if there is enough place for this participation
      if participation.size <= places_left
        if participation.set_waiting_list!
          places_left = places_left - participation.size
          participation.user_subscribed_email_for_teacher
          ParticipationMailer.delay.a_place_opened(participation)
        end
      end
      return if places_left == 0
    end
    nil
  end

  # Update structure meta datas when participation change to update the number of "Places left"
  #
  # @return nil
  def update_structure_meta_datas
    planning.structure.update_meta_datas
    nil
  end

  # Creates a user profile after a participation is created
  #
  # @return nil
  def create_user_profile
    user_profile = UserProfile.update_info(structure, user)
    structure.add_tags_on(user_profile, UserProfile::DEFAULT_TAGS[:jpo_2014])
    nil
  end

  # If it was the last participation to be sold, tell the teacher about it
  #
  # @return nil
  def sends_email_if_no_more_place
    if self.structure.total_jpo_places_left == 0 and self.structure.jpo_email_status != 'no_more_place'
      self.structure.jpo_email_status = 'no_more_place'
      self.structure.save
      ParticipationMailer.delay.no_more_place(self.structure)
    end
  end

  # Send an email to the person who has invited him if it was the case
  #
  # @return nil
  def check_if_was_on_invite
    _email = self.user.email
    InvitedUser::Student.where(email: _email).each do |invited_user|
      ParticipationMailer.delay.inform_invitation_success_for_jpo(invited_user.referrer, self.user, self)
    end
  end
end
