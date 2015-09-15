class ParticipationRequest::Notifier

  def initialize(participation_request)
    @participation_request = participation_request
    @user = @participation_request.user
    @structure = @participation_request.structure
    @admin = @structure.main_contact
  end

  # Notify the creation of PR.
  def notify_request_creation
    # Notify via emails.
    mailer.delay(queue: 'mailers').you_received_a_request(@participation_request)
    mailer.delay(queue: 'mailers').you_sent_a_request(@participation_request)

    # Notify via SMS.
    structure_number = @structure.principal_mobile
    if structure_number and @structure.sms_opt_in?
      message = @participation_request.decorate.sms_message_for_new_request_to_teacher
      @structure.delay(priority: 10).send_sms(message, structure_number.number)
    end

    if @user.phone_number and @user.sms_opt_in?
      message = @participation_request.decorate.sms_message_for_new_request_to_user

      @user.delay(priority: 10).send_sms(message, @user.phone_number)
    end

    true
  end

  def notify_request_accepted(accepted_by, message)
    if accepted_by == 'Structure'
      mailer.delay(queue: 'mailers').request_has_been_accepted_by_teacher_to_user(
        @participation_request, message)
    else
      mailer.delay(queue: 'mailers').request_has_been_accepted_by_user_to_teacher(
        @participation_request, message)
    end
  end

  private

  def mailer
    @mailer ||= if @participation_request.from_personal_website?
                  StructureWebsiteParticipationRequestMailer
                else
                  ParticipationRequestMailer
                end
  end
end
