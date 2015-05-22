# encoding: utf-8
class ParticipationRequestMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  helper :application, :structures, :email_actions

  default from: 'CoursAvenue <hello@coursavenue.com>'

  ######################################################################
  # For Participation Requests                                         #
  ######################################################################
  def you_sent_a_request(participation_request)
    @message = participation_request.conversation.messages.first
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email,
         subject: "Demande d'inscription envoyée - #{@structure.name}",
         reply_to: generate_reply_to('admin')
  end

  def you_received_a_request(participation_request)
    @message = participation_request.conversation.messages.first
    retrieve_participation_request_variables(participation_request)
    mail to: @admin.email,
         subject: "Demande d'inscription - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  def you_received_a_request_stage_1(participation_request)
    @message = participation_request.conversation.messages.first
    retrieve_participation_request_variables(participation_request)
    mail to: @admin.email,
         subject: "Rappel - Confirmez l'inscription - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  def you_received_a_request_stage_2(participation_request)
    @message = participation_request.conversation.messages.first
    retrieve_participation_request_variables(participation_request)
    mail to: @admin.email,
         subject: "Dernier rappel - Confirmez l'inscription - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  ######################################################################
  # Request has been accepted                                          #
  ######################################################################
  def request_has_been_accepted_by_user_to_teacher(participation_request, message=nil)
    retrieve_participation_request_variables(participation_request)
    @message = message if message
    mail to: @admin.email, subject: "Inscription acceptée - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  def request_has_been_accepted_by_teacher_to_user(participation_request, message=nil)
    retrieve_participation_request_variables(participation_request)
    @upcoming_participation_requests = @user.participation_requests.accepted.upcoming.reject{ |pr| pr == participation_request }
    @message = message if message
    mail to: @user.email, subject: "Inscription acceptée - #{@structure.name}",
         reply_to: generate_reply_to('user')
  end

  ######################################################################
  # Request has been discussed                                         #
  ######################################################################
  def request_has_been_discussed_by_user_to_teacher(participation_request, message)
    @message = message
    retrieve_participation_request_variables(participation_request)
    mail to: @admin.email, subject: "Nouveau message - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  def request_has_been_discussed_by_teacher_to_user(participation_request, message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @user.email, subject: "Nouveau message - #{@structure.name}",
         reply_to: generate_reply_to('user')
  end

  ######################################################################
  # Request has been modified                                          #
  ######################################################################
  def request_has_been_modified_by_user_to_teacher(participation_request, message)
    @message = message
    retrieve_participation_request_variables(participation_request)
    mail to: @admin.email,
         subject: (@participation_request.old_course_id.present? ? 'Changement de cours' : 'Changement de date') + " - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  def request_has_been_modified_by_teacher_to_user(participation_request, message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @user.email,
         subject: (@participation_request.old_course_id.present? ? 'Changement de cours' : 'Changement de date') + " - #{@structure.name}",
         reply_to: generate_reply_to('user')
  end

  def request_has_been_modified_by_teacher_to_user_stage_1(participation_request)
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email, subject: "Rappel - Confirmez votre inscription - #{@structure.name}",
         reply_to: generate_reply_to('user')
  end

  def request_has_been_modified_by_teacher_to_user_stage_2(participation_request)
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email, subject: "Dernier rappel - Confirmation d'inscription - #{@structure.name}",
         reply_to: generate_reply_to('user')
  end

  ######################################################################
  # Request has been canceled                                          #
  ######################################################################
  def request_has_been_canceled_by_teacher_to_user(participation_request, message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @user.email, subject: "Inscription annulée - #{@structure.name}",
         reply_to: generate_reply_to('user')
  end

  def request_has_been_canceled_by_user_to_teacher(participation_request,  message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @admin.email, subject: "Inscription annulée - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  def recap_for_teacher(structure, participation_requests)
    @participation_requests = participation_requests
    @structure              = @participation_requests.first.structure
    @admin                  = @structure.main_contact
    @nb_users               = @participation_requests.map(&:user).uniq.count
    mail to: @admin.email, subject: "Pour mémoire - Inscriptions pour demain"
  end

  def recap_for_user(user, participation_requests)
    @participation_requests = participation_requests
    @user                   = user
    mail to: @user.email, subject: "Pour mémoire - Planning de demain"
  end

  ######################################################################
  # After the course                                                   #
  ######################################################################
  def how_was_the_student(participation_request)
    # retrieve_participation_request_variables(participation_request)
    # mail to: @user.email, subject: "Qu'en avez-vous pensé ?"
  end

  def how_was_the_trial(participation_request)
    retrieve_participation_request_variables(participation_request)
    @comment = @structure.comments.build
    mail to: @user.email, subject: "Qu'en avez-vous pensé ?"
  end

  def how_was_the_trial_stage_1(participation_request)
    retrieve_participation_request_variables(participation_request)
    @comment = @structure.comments.build
    mail to: @user.email, subject: "Pensez à laisser votre témoignage sur #{@structure.name}"
  end

  def how_was_the_trial_stage_2(participation_request)
    retrieve_participation_request_variables(participation_request)
    @comment = @structure.comments.build
    mail to: @user.email,
         subject: "Pensez à laisser votre témoignage sur #{@structure.name}",
         template_name: 'how_was_the_trial_stage_1'
  end

  def suggest_other_structures(user, structure)
    @user       = user
    @structure  = structure
    @subject    = structure.dominant_root_subject
    @city       = structure.dominant_city
    mail to: @user.email, subject: "Alternatives à #{structure.name}"
  end

  ######################################################################
  # Payments                                                           #
  ######################################################################

  # Send the invoice to the user.
  #
  # @param user                  The user to send the invoice to
  # @param teacher               The teacher of the course
  # @param participation_request The related participation request
  #
  # @return
  def send_invoice_to_user(participation_request)
    @user                  = participation_request.user
    @structure             = participation_request.structure
    @invoice               = participation_request.invoice
    @participation_request = participation_request.decorate

    mail to: @user.email,
      subject: "Votre facture du cours du #{ @participation_request.day_and_hour } avec #{ @structure.name }"
  end

  def send_charge_refunded_to_user(participation_request)
    @user                  = participation_request.user
    @structure             = participation_request.structure
    @participation_request = participation_request.decorate

    mail to: @user.email,
      subject: ""
  end

  def send_charge_refunded_to_teacher(participation_request)
    @user                  = participation_request.user
    @structure             = participation_request.structure
    @participation_request = participation_request.decorate

    mail to: @structure.email,
      subject: ""
  end

  private

  def retrieve_participation_request_variables(participation_request)
    @participation_request           = participation_request
    @participation_request_decorator = participation_request.decorate
    @course                          = participation_request.course
    @place                           = participation_request.place
    @structure                       = participation_request.structure
    @admin                           = participation_request.structure.main_contact
    @user                            = participation_request.user
    @conversation                    = participation_request.conversation
  end

  # Generate the reply_to address using ReplyTokens.
  # Replies will be handled by EmailProcessor
  #
  # @return a String
  def generate_reply_to(sender_type = 'admin')
    @reply_token = ReplyToken.create(reply_type: 'participation_request')
    @reply_token.data = {
      sender_type:              sender_type,
      sender_id:                sender_type == 'admin' ? @admin.id : @user.id,
      participation_request_id: @participation_request.id,
      gmail_action_name:        "Confirmer l'inscription"
    }
    @reply_token.save

    return "CoursAvenue <#{@reply_token.token}@#{CoursAvenue::Application::MANDRILL_REPLY_TO_DOMAIN}>"
  end

end
