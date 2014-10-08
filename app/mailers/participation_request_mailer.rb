# encoding: utf-8
class ParticipationRequestMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'
  helper :structures

  default from: 'CoursAvenue <hello@coursavenue.com>'

  ######################################################################
  # For Participation Requests                                         #
  ######################################################################
  def you_received_a_request(participation_request)
    @participation_request = participation_request
    @structure             = participation_request.structure
    @admin                 = participation_request.structure.main_contact
    @user                  = participation_request.user
    @message               = participation_request.conversation.messages.first
    @conversation          = participation_request.conversation
    mail to: @admin.email,
         subject: "Demande d'inscription à un cours d'essai - #{@user.name}"
  end

  def you_received_a_request_stage_1(participation_request)
    @participation_request = participation_request
    @structure             = participation_request.structure
    @admin                 = participation_request.structure.main_contact
    @user                  = participation_request.user
    @message               = participation_request.conversation.messages.first
    @conversation          = participation_request.conversation
    mail to: @admin.email,
         subject: "Rappel - Confirmez l'inscription - #{@user.name}"
  end

  def you_received_a_request_stage_2(participation_request)
    @participation_request = participation_request
    @structure             = participation_request.structure
    @admin                 = participation_request.structure.main_contact
    @user                  = participation_request.user
    @message               = participation_request.conversation.messages.first
    @conversation          = participation_request.conversation
    mail to: @admin.email,
         subject: "Dernier rappel - Confirmez l'inscription - #{@user.name}"
  end

  ######################################################################
  # Request has been accepted                                          #
  ######################################################################
  def request_has_been_accepted_by_user_to_teacher(participation_request, message=nil)
    retrieve_participation_request_variables(participation_request)
    @message = message if message
    mail to: @admin.email, subject: "Inscription acceptée - #{@user.name}"
  end

  def request_has_been_accepted_by_teacher_to_user(participation_request, message=nil)
    retrieve_participation_request_variables(participation_request)
    @upcoming_participation_requests = participation_request.user.participation_requests.upcoming.reject{ |pr| pr == participation_request }
    @message = message if message
    mail to: @user.email, subject: "Inscription acceptée - #{@structure.name}"
  end

  ######################################################################
  # Request has been modified                                          #
  ######################################################################
  def request_has_been_modified_by_user_to_teacher(participation_request, message)
    @message = message
    retrieve_participation_request_variables(participation_request)
    mail to: @admin.email, subject: "Nouvelle proposition de créneau - #{@user.name}"
  end

  def request_has_been_modified_by_teacher_to_user(participation_request, message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @user.email, subject: "Nouvelle proposition de créneau - #{@structure.name}"
  end

  def request_has_been_modified_by_teacher_to_user_stage_1(participation_request)
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email, subject: "Rappel - Confirmez votre inscription - #{@structure.name}"
  end

  def request_has_been_modified_by_teacher_to_user_stage_2(participation_request)
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email, subject: "Dernier rappel - Confirmation d'inscription - #{@structure.name}"
  end

  ######################################################################
  # Request has been declinded                                         #
  ######################################################################
  def request_has_been_declined_by_teacher_to_user(participation_request, message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @user.email, subject: "Inscription refusé - #{@structure.name}"
  end

  def request_has_been_declined_by_user_to_teacher(participation_request, message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @admin.email, subject: "Inscription refusé - #{@user.name}"
  end

  ######################################################################
  # Request has been canceled                                          #
  ######################################################################
  def request_has_been_canceled_by_teacher_to_user(participation_request, message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @user.email, subject: "Inscription annulé - #{@structure.name}"
  end

  def request_has_been_canceled_by_user_to_teacher(participation_request,  message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @admin.email, subject: "Inscription annulé - #{@user.name}"
  end

  def recap_for_teacher(structure, participation_requests)
    @participation_requests = participation_requests
    @structure              = @participation_requests.first.structure
    @admin                  = @structure.main_contact
    @nb_users               = @participation_requests.map(&:user).uniq.count
    mail to: @admin.email, subject: "Pour mémoire - Inscriptions pour demain"
  end

  ######################################################################
  # After the course                                                   #
  ######################################################################
  def how_was_the_trial(participation_request)
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email, subject: "Qu'en avez-vous pensé ?"
  end

  def how_was_the_trial_stage_1(participation_request)
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email, subject: "Pensez à laisser votre témoignage sur #{@structure.name}"
  end

  private

  def retrieve_participation_request_variables(participation_request)
    @participation_request = participation_request
    @course                = @participation_request.course
    @place                 = @participation_request.planning.place
    @structure             = participation_request.structure
    @admin                 = participation_request.structure.main_contact
    @user                  = participation_request.user
    @conversation          = participation_request.conversation
  end
end
