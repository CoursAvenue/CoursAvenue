# encoding: utf-8
class StructureWebsiteParticipationRequestMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'newsletter'

  helper :application, :structures, :email_actions

  default from: 'CoursAvenue <hello@coursavenue.com>'

  def you_sent_a_request(participation_request)
    @message = participation_request.conversation.messages.first
    retrieve_participation_request_variables(participation_request)
    mail to: @user.email,
         from: "#{@structure.name} <hello@coursavenue.com>",
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
    if participation_request.from_personal_website?
      @participation_request_url_for_user = structure_website_participation_request_url(@participation_request, subdomain: @structure.subdomain_slug)
    else
      @participation_request_url_for_user = user_participation_request_url(@user, @participation_request, subdomain: 'www')
    end
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
