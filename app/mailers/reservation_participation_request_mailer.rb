# encoding: utf-8
class ReservationParticipationRequestMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'newsletter'

  helper :application, :structures, :email_actions

  default from: 'CoursAvenue <hello@coursavenue.com>'

  def you_sent_a_request(participation_request)
    @message = participation_request.conversation.messages.first
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email,
         from: "#{strip_name(@structure.name)} <hello@coursavenue.com>",
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
    @message = message if message
    mail to: @user.email, subject: "Inscription acceptée - #{@structure.name}",
         from: "#{strip_name(@structure.name)} <hello@coursavenue.com>",
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
    @message = message
    retrieve_participation_request_variables(participation_request)
    mail to: @admin.email, subject: "Nouveau message - #{@user.name}",
         reply_to: generate_reply_to('admin')
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

  def request_has_been_modified_by_teacher_to_user(participation_request, message=nil)
    retrieve_participation_request_variables(participation_request)
    @message = message if message
    mail to: @user.email, subject: "Inscription acceptée - #{@structure.name}",
         from: "#{strip_name(@structure.name)} <hello@coursavenue.com>",
         reply_to: generate_reply_to('user')
  end

  ######################################################################
  # Request has been canceled                                          #
  ######################################################################
  def request_has_been_canceled_by_teacher_to_user(participation_request, message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @user.email, subject: "Inscription annulée - #{@structure.name}",
         from: "#{strip_name(@structure.name)} <hello@coursavenue.com>",
         reply_to: generate_reply_to('user')
  end

  def request_has_been_canceled_by_user_to_teacher(participation_request,  message)
    retrieve_participation_request_variables(participation_request)
    @message = message
    mail to: @admin.email, subject: "Inscription annulée - #{@user.name}",
         reply_to: generate_reply_to('admin')
  end

  private

  def retrieve_participation_request_variables(participation_request)
    @participation_request           = participation_request
    @participation_request_decorator = participation_request.decorate
    @course                          = participation_request.course
    @place                           = participation_request.place
    @structure                       = participation_request.structure
    @admin                           = participation_request.structure.admin
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

    return "#{@participation_request.user.name} <#{@reply_token.token}@#{CoursAvenue::Application::MANDRILL_REPLY_TO_DOMAIN}>"
  end

  # https://gist.github.com/aliou/4e84aaf8b22706915767
  # Mandrill doesn't like some characters in the `from` attribute. In this mailer, we are using the
  # structure's name in this mailer, so we also need to format it.
  def strip_name(structure_name = "")
    name = structure_name.dup
    ["\"", "(", ",", ":", ";", "<", ">", "["].each do |char|
      name.tr!(char, '')
    end

    name
  end

end
