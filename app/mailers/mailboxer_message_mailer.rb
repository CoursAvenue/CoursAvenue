# encoding: utf-8
class MailboxerMessageMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  include ActionView::Helpers::SanitizeHelper
  include ConversationsHelper

  layout 'email'

  helper :application

  default from: "\"L'équipe CoursAvenue\" <hello@coursavenue.com>"

  # Sends and email for indicating a new message or a reply to a receiver.
  # It calls new_message_email if notifing a new message and reply_message_email
  # when indicating a reply to an already created conversation.
  def send_email(message, receiver)
    @conversation = message.conversation
    if @conversation.lock_email_notification_once == true
      @conversation.update_column :lock_email_notification_once, false
      return false
    end

    # Don't use the mailboxer mailer for community public questions.
    if @conversation.mailboxer_label_id == Mailboxer::Label::PUBLIC_QUESTION.id
      return false
    end

    if receiver.is_a? User
      send_email_to_user(message, receiver)
    else
      send_email_to_admin(message, receiver)
    end
  end

  def send_email_to_user(message, receiver)
    if message.conversation.messages.size > 1
      reply_message_email_to_user(message, receiver)
    else
      new_message_email_to_user(message, receiver)
    end
  end

  def send_email_to_admin(message, receiver)
    if message.conversation.messages.size > 1
      reply_message_email_to_admin(message, receiver)
    else
      new_message_email_to_admin(message, receiver)
    end
  end

  # Sends an email for indicating a new message for the receiver
  def new_message_email_to_user(message, receiver)
    @message     = message
    @user        = receiver
    @structure   = message.sender.structure

    mail to: @user.email,
         subject: t('mailboxer.message_mailer.subject_new', sender: @structure.name),
         template_name: 'new_message_email_to_user',
         reply_to: generate_reply_to('user')
  end

  def new_message_email_to_admin(message, receiver)
    # Don't send email if message is new AND the label is comment or community because we show
    # this message in new comment email
    return if message.conversation.mailboxer_label_id == Mailboxer::Label::COMMENT.id
    return if message.conversation.mailboxer_label_id == Mailboxer::Label::REQUEST.id
    return if message.conversation.mailboxer_label_id == Mailboxer::Label::PUBLIC_QUESTION.id

    @message      = message
    @conversation = message.conversation
    @admin        = receiver
    @structure    = @admin.structure
    @user         = message.sender
    if @conversation.mailboxer_label_id == Mailboxer::Label::INFORMATION.id
      mail to: @admin.email,
           subject: t('mailboxer.message_mailer.information_subject_new', sender: @user.name),
           template_name: 'new_information_message_email_to_admin',
           reply_to: generate_reply_to('admin')
    else
      mail to: @admin.email,
           subject: t('mailboxer.message_mailer.subject_new', sender: @user.name),
           template_name: 'new_message_email_to_admin',
           reply_to: generate_reply_to('admin')
    end
  end

  # Sends and email for indicating a reply in an already created conversation
  # User replying
  def reply_message_email_to_user(message, receiver)
    @message   = message
    @user      = receiver
    @structure = message.sender.try(:structure)
    return if @structure.nil?
    mail to: @user.email,
         subject: t('mailboxer.message_mailer.subject_reply', sender: @structure.name),
         template_name: 'reply_message_email_to_user',
         reply_to: generate_reply_to('user')
  end

  def reply_message_email_to_admin(message, receiver)
    @message   = message
    @admin     = receiver
    @user      = message.sender
    @structure = @admin.structure

    mail to: @admin.email,
         subject: t('mailboxer.message_mailer.subject_reply', sender: @user.name),
         template_name: 'reply_message_email_to_admin',
         reply_to: generate_reply_to('admin')
  end

  private

  def generate_reply_to(sender_type = 'admin')
    reply_token = ReplyToken.create(reply_type: 'conversation')
    reply_token.data = {
      sender_type:     sender_type,
      sender_id:       sender_type == 'admin' ? @admin.id : @user.id,
      conversation_id: @conversation.id
    }
    reply_token.save

    return "CoursAvenue <#{reply_token.token}@#{CoursAvenue::Application::MANDRILL_REPLY_TO_DOMAIN}>"
  end
end
