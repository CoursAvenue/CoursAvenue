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

  def request_has_been_accepted(participation_request)
    @participation_request = participation_request
    @structure             = participation_request.structure
    @admin                 = participation_request.structure.main_contact
    @user                  = participation_request.user
    @conversation          = participation_request.conversation

    mail to: @admin.email, subject: "Inscription acceptée - #{@user.name}"
  end

  def request_has_been_modified(participation_request)
    @participation_request = participation_request
    @structure             = participation_request.structure
    @admin                 = participation_request.structure.main_contact
    @user                  = participation_request.user
    @conversation          = participation_request.conversation
    if participation_request.last_modified_by == 'Structure'
      mail to: @admin.email, subject: "Inscription modifiée - #{@user.name}",
           template: 'request_has_been_modified_by_teacher_to_teacher'
    elsif participation_request.last_modified_by == 'User'
      mail to: @admin.email, subject: "Confirmez l'inscription - #{@user.name}",
           template: 'request_has_been_modified_by_user_to_teacher'
    end
  end

  def request_has_been_declined(participation_request)
    @participation_request = participation_request
    @structure             = participation_request.structure
    @admin                 = participation_request.structure.main_contact
    @user                  = participation_request.user
    @conversation          = participation_request.conversation

    mail to: @admin.email, subject: "Inscription refusée - #{@user.name}"
  end
end
