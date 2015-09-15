class ParticipationRequest < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions
  extend FriendlyId
  include Concerns::HasRandomToken

  friendly_id :token, use: [:finders]

  acts_as_paranoid

  STATE                 = %w(accepted treated pending canceled)
  PARAMS_THAT_MODIFY_PR = %w(date start_time end_time planning_id course_id)

  attr_accessible :state, :date, :start_time, :end_time, :mailboxer_conversation_id,
    :planning_id, :last_modified_by, :course_id, :user, :structure, :conversation,
    :cancelation_reason_id, :report_reason_id, :report_reason_text, :reported_at,
    :old_course_id, :structure_responded, :street, :zip_code, :city_id, :at_student_home,
    :participants_attributes, :structure_id, :from_personal_website, :token, :charged_at,
    :stripe_fee

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :conversation, class_name: 'Mailboxer::Conversation', foreign_key:
    'mailboxer_conversation_id', touch: true, dependent: :destroy
  belongs_to :planning
  belongs_to :city
  belongs_to :course
  def course
    Course.unscoped{ super }
  end
  belongs_to :user
  def user
    User.unscoped{ super }
  end
  belongs_to :structure
  def structure
    Structure.unscoped{ super }
  end
  belongs_to :cancelation_reason, class_name: 'ParticipationRequest::CancelationReason'
  belongs_to :report_reason     , class_name: 'ParticipationRequest::ReportReason'

  has_many :participants, class_name: 'ParticipationRequest::Participant'
  has_many :prices, through: :participants
  has_one :invoice, class_name: 'ParticipationRequest::Invoice'

  has_one :state,        class_name: 'ParticipationRequest::State',        dependent: :destroy
  has_one :conversation, class_name: 'ParticipationRequest::Conversation', dependent: :destroy

  accepts_nested_attributes_for :participants,
    reject_if: :reject_participants,
    allow_destroy: false

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  before_validation :set_date_if_empty
  before_create     :set_default_attributes

  after_create :touch_user
  after_create :set_check_for_disable_later
  after_create :notify_super_admin_of_more_than_five_requests

  before_save       :update_times
  after_save        :update_structure_response_rate

  after_destroy     :touch_user

  ######################################################################
  # Validation                                                         #
  ######################################################################
  validates :date, presence: true

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :accepted,                -> { joins(:state).where("participation_request_states.state LIKE 'accepted'") }
  scope :not_accepted,            -> { joins(:state).where("participation_request_states.state NOT LIKE 'accepted'") }
  scope :pending,                 -> { joins(:state).where("participation_request_states.state LIKE 'pending'") }
  scope :treated,                 -> { joins(:state).where("participation_request_states.state LIKE 'treated'") }
  scope :canceled,                -> { joins(:state).where("participation_request_states.state LIKE 'canceled'") }
  scope :upcoming,                -> { where( arel_table[:date].gteq(Date.today) ).order("date ASC") }
  scope :past,                    -> { where( arel_table[:date].lt(Date.today) ).order("date ASC") }
  scope :tomorrow,                -> { accepted.where(date: Date.tomorrow) }
  scope :structure_not_responded, -> { where.not( structure_responded: true ) }
  scope :charged,                 -> { where.not( charged_at: nil ) }
  scope :from_personal_website,   -> { where( from_personal_website: true ) }
  scope :from_personal_ca,        -> { where.not( from_personal_website: true ) }

  ######################################################################
  # Delegations                                                        #
  ######################################################################

  delegate :pending?, to: :state, prefix: false
  delegate :treated?, to: :state, prefix: false
  delegate :accepted?, to: :state, prefix: false
  delegate :canceled?, to: :state, prefix: false

  delegate :treat!, to: :state, prefix: false
  delegate :accept!, to: :state, prefix: false
  delegate :cancel!, to: :state, prefix: false

  ######################################################################
  # Create a ParticipationRequest if everything is correct, and if it is, it also create a conversation
  #
  # @return ParticipationRequest
  def self.create_and_send_message(request_attributes, user)
    structure = Structure.friendly.find(request_attributes[:structure_id])
    # request_attributes[:message][:body] = StringHelper.replace_contact_infos(request_attributes[:message][:body])
    request_attributes      = self.set_start_time(request_attributes)
    participants_attributes = { participants_attributes: (request_attributes['participants_attributes'] || [{ number: 1}]) }
    new_request_attributes  = request_attributes.slice(*ParticipationRequest.attribute_names.map(&:to_sym))
    new_request_attributes  = new_request_attributes.merge(participants_attributes)
    participation_request   = ParticipationRequest.new new_request_attributes

    participation_request.user = user
    participation_request.save
    if participation_request.persisted?
      structure.create_or_update_user_profile_for_user(user, UserProfile::DEFAULT_TAGS[:participation_request])
      create_conversation if self.conversation.nil?
      conversation.send_request!(message)
    end
    participation_request
  end

  # Tells if the resource type is waiting for an answer
  # @param resource_type='Structure' [type] [description]
  #
  # @return Boolean
  def pending_for?(resource_type='Structure')
    (self.state.pending? and self.last_modified_by != resource_type)
  end

  # Accept request and send a message to user.
  # @param message String
  #
  # @return Boolean
  def accept!(message_body, last_modified_by='Structure')
    # message_body = StringHelper.replace_contact_infos(message_body)
    self.last_modified_by    = last_modified_by
    self.state.accept!
    message = conversation.reply!(message_body, last_modified_by)
    self.structure_responded = true if last_modified_by == 'Structure'
    save

    if chargeable?
      charge!
    end

    if self.last_modified_by == 'Structure'
      mailer.delay.request_has_been_accepted_by_teacher_to_user(self, message)
    elsif self.last_modified_by == 'User'
      mailer.delay.request_has_been_accepted_by_user_to_teacher(self, message)
    end
  end

  #
  # Tells wether or not we should charge the PR
  #
  # @return Boolean
  def chargeable?
    (price != 0 and
      structure.can_receive_payments? and
      course.accepts_payment? and
      from_personal_website? and
      user.stripe_customer_id)
  end

  # Modify request and inform user about it
  # @param message String
  #
  # @return Boolean
  def modify_date!(message_body, new_params, last_modified_by='Structure')
    # message_body          = StringHelper.replace_contact_infos(message_body)
    new_params            = ParticipationRequest.set_start_time(new_params)
    self.last_modified_by = last_modified_by
    # We don not update_attributes because self.course_id_was won't work...
    self.assign_attributes new_params
    # Set old_course_id to nil if the user don't change it and modify just the date
    self.old_course_id       = (self.course_id_was == self.course_id ? nil : self.course_id_was)
    self.state.accept!
    if message_body.present?
      message = conversation.reply!(message_body, last_modified_by)
    end
    self.structure_responded = true if last_modified_by == 'Structure'

    # If we change the course type, make sure to update the date.
    if self.old_course_id.present? and new_params[:date].present?
      self.date = Date.parse(new_params[:date])
    end

    save

    if self.last_modified_by == 'Structure'
      mailer.delay.request_has_been_accepted_by_teacher_to_user(self, message)
    elsif self.last_modified_by == 'User'
      mailer.delay.request_has_been_accepted_by_user_to_teacher(self, message)
    end
  end

  # Discuss the request and inform user about it
  # @param message String
  #
  # @return Boolean
  def discuss!(message_body, discussed_by='Structure')
    # message_body             = StringHelper.replace_contact_infos(message_body)
    message = conersation.reply!(message_body, discussed_by)
    treat!('message') if pending?
    self.structure_responded = true if discussed_by == 'Structure'
    save
    if discussed_by == 'Structure'
      mailer.delay.request_has_been_discussed_by_teacher_to_user(self, message)
    elsif discussed_by == 'User'
      mailer.delay.request_has_been_discussed_by_user_to_teacher(self, message)
    end
  end

  # Cancel a proposition
  # @param message [type] [description]
  #
  # @return Boolean
  def cancel!(message_body, cancelation_reason_id, last_modified_by='Structure')
    # message_body               = StringHelper.replace_contact_infos(message_body)
    self.cancelation_reason_id = cancelation_reason_id
    self.last_modified_by      = last_modified_by
    self.state.cancel!
    message                    = conversation.reply!(message_body, last_modified_by)
    self.structure_responded   = true if last_modified_by == 'Structure'
    save

    if self.invoice.present?
      refund!
    end

    if self.last_modified_by == 'Structure'
      mailer.delay.request_has_been_canceled_by_teacher_to_user(self, message)
    elsif self.last_modified_by == 'User'
      mailer.delay.request_has_been_canceled_by_user_to_teacher(self, message)
    end
  end

  def place
    if at_student_home?
      course.home_place
    elsif planning
      planning.place
    elsif course and course.place
      course.place
    elsif structure
      structure.places.first
    end
  end

  def levels
    if self.planning
      self.planning.levels
    else
      self.course.levels
    end
  end

  # Tells if the PR is past or not.
  #
  # @return Boolean, wether the date is passed
  def past?
    date < Date.today
  end

  def nb_participants
    participants.map(&:number).reduce(&:+) || 0
  end

  # The cost of this Participation Request in Euros.
  #
  # @return an integer
  def price
    participants.map(&:total_price).reduce(0, :+).to_i
  end

  # Whether the Participation Request has been charged to the user.
  #
  # @return a Boolean
  def charged?
    charged_at.present?
  end

  # Retrieve the `Stripe::Charge` associated with the participation request.
  #
  # @return nil or Stripe::Charge
  def stripe_charge
    return nil if self.stripe_charge_id.nil?

    Stripe::Charge.retrieve(stripe_charge_id)
  end

  # Charge the amount of the participation request to the user.
  #
  # @param token The token needed to create the stripe customer, if it doesn't already exists.
  #
  # @return the charge or nil
  def charge!(token = nil)
    return nil if ! structure.can_receive_payments?

    customer = user.stripe_customer || user.create_stripe_customer(token)
    return nil if customer.nil?

    charge = Stripe::Charge.create({
      amount:          price * 100,
      currency:        Subscription::CURRENCY,
      customer:        customer.id,
      destination:     structure.stripe_managed_account,
      application_fee: Subscription::APPLICATION_FEE
    })
    balance_transaction = Stripe::BalanceTransaction.retrieve charge.balance_transaction

    self.delay.create_and_send_invoice

    self.stripe_charge_id = charge.id
    self.charged_at       = Time.now
    self.stripe_fee       = balance_transaction.fee / 100.0 # Because fee are in cents
    self.save

    charge
  end

  # Refund the amount of the participation request to the user.
  #
  # @return
  def refund!
    return nil if stripe_charge_id.nil? or stripe_charge.refunded or refunded?

    charge = stripe_charge
    refund = charge.refunds.create

    # ParticipationRequestMailer.delay(queue: 'mailers').send_charge_refunded_to_teacher(self)
    # ParticipationRequestMailer.delay(queue: 'mailers').send_charge_refunded_to_user(self)

    self.refunded_at =  Time.now
    save

    refund
  end

  def course_address
    if !at_student_home?
      if planning and planning.place
        planning.place.address
      elsif course.place
        course.place.address
      end
    end
  end

  def refunded?
    refunded_at.present?
  end

  def unanswered?
    self.created_at < 2.days.ago and self.state.pending? and
      self.conversation.messages.length < 2 and self.last_modified_by == 'User'
  end

  # Rebook the participation request.
  #
  # @return the new participation request.
  def rebook!(options)
    # options[:message][:body] = StringHelper.replace_contact_infos(options[:message][:body])
    new_attributes = ParticipationRequest.set_start_time(options)

    new_attributes.merge!({
      planning_id: self.planning_id,
      structure: self.structure,
      last_modified_by: 'structure',
      course_id: self.course_id,
      street: self.street,
      zip_code: self.zip_code,
      city_id: self.city_id,
      from_personal_website: self.from_personal_website,
      at_student_home: self.at_student_home,
      participants_attributes: participants.map { |p| { number: p.number } }
    })

    participation_request = ParticipationRequest.new(new_attributes)
    participation_request.user = self.user

    participation_request.save
    if participation_request.valid?
      recipients = self.user
      _conversation = (participation_request.conversation or
                       participation_request.create_conversation)
      _conversation.send_request(options[:message][:body], self.structure)
    end

    participation_request
  end

  def notify_super_admin_of_more_than_five_requests
    request_count = user.participation_requests.select { |pr| pr.created_at > 1.week.ago }.count
    if request_count > 5
      SuperAdminMailer.delay(queue: 'mailers').alert_for_user_with_more_than_five_requests(user)
    end
  end

  private

  # Set state to pending by default when creating
  #
  # @return nil
  def set_default_attributes
    self.last_modified_by ||= 'User'
    self.start_time       ||= self.planning.start_time if self.planning and self.start_time.nil?
    self.end_time         ||= self.planning.end_time   if self.planning
    self.end_time         ||= self.start_time + 1.hour if self.start_time
    self.course           ||= self.planning.course     if self.planning
    self.create_state
    nil
  end

  # Update start and end_time if planning changed
  #
  # @return nil
  def update_times
    if self.planning_id_changed?
      self.start_time = self.planning.start_time if self.planning
      self.end_time   = self.planning.end_time   if self.planning
      self.end_time   ||= self.start_time + 1.hour if self.start_time
    end
    nil
  end

  # When a request is created (always by user), we alert the teacher
  #
  # @return nil
  def send_email_to_teacher
    mailer.delay.you_received_a_request(self)
  end

  # When a request is created we inform the user
  #
  # @return nil
  def send_email_to_user
    mailer.delay.you_sent_a_request(self)
    nil
  end

  # When a request is created (always by user), we alert the teacher via sms
  #
  # @return nil
  def send_sms_to_teacher
    structure.notify_new_participation_request_via_sms(self)
  end

  # We destroy the Mailboxer::Conversation object attached to the PR
  def destroy_conversation_attached
    self.conversation.destroy
  end

  # If start_hour and start_min are passed, we transform it into a start_time
  # @return request_attributes without start_hour and start_min but with start_time
  def self.set_start_time(request_attributes)
    if request_attributes[:planning_id].blank? and request_attributes[:start_hour] and request_attributes[:start_min]
      # Be careful to add 0 at the end to remove local time.
      request_attributes[:start_time] = Time.new(2000, 1, 1, request_attributes[:start_hour].to_i, request_attributes[:start_min].to_i, 0, 0)
      request_attributes.delete(:start_hour)
      request_attributes.delete(:start_min)
    end
    request_attributes
  end

  def touch_user
    self.user.touch
  end

  def reject_participants attributes
    return (attributes[:number].blank? or attributes[:number] == '0')
  end

  # Set the date to the start_date of the planning if no date is given
  # Usually correspond to training courses.
  def set_date_if_empty
    self.date ||= self.planning.start_date if self.planning
  end

  # Create and send the invoice.
  #
  # @return
  def create_and_send_invoice
    self.invoice = ParticipationRequest::Invoice.create(participation_request: self,
                                                        payed_at:              Time.now)
    save

    # ParticipationRequestMailer.delay(queue: 'mailers').send_invoice_to_user(self)
  end

  def mailer
    if from_personal_website?
      StructureWebsiteParticipationRequestMailer
    else
      ParticipationRequestMailer
    end
  end

  # If participation request is from personal website, send a SMS to user
  def send_sms_to_user
    if user.phone_number and user.sms_opt_in?
      message = self.decorate.sms_message_for_new_request_to_user

      user.delay.send_sms(message, user.phone_number)
    end
  end

  def update_structure_response_rate
    structure.delay.compute_response_rate
  end

  def set_check_for_disable_later
    last_two = structure.participation_requests.last(Structure::DISABLE_ON_PR_NOT_ANSWERED_COUNT) - [ self ]
    if last_two.all?(&:unanswered?)
      structure.delay(run_at: 3.days.from_now).check_for_disable
    end
  end
  handle_asynchronously :set_check_for_disable_later
end
