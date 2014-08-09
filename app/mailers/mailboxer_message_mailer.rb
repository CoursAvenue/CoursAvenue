# encoding: utf-8
class MailboxerMessageMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  layout 'email'

  include ActionView::Helpers::SanitizeHelper

  default from: "\"L'équipe CoursAvenue\" <contact@coursavenue.com>"

  # Sends and email for indicating a new message or a reply to a receiver.
  # It calls new_message_email if notifing a new message and reply_message_email
  # when indicating a reply to an already created conversation.
  def send_email(message, receiver)
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
    @token       = @user.generate_and_set_reset_password_token if !@user.active?

    mail to: @user.email,
         subject: t('mailboxer.message_mailer.subject_new', sender: @structure.name),
         template_name: 'new_message_email_to_user'
  end

  def new_message_email_to_admin(message, receiver)
    # Don't send email if message is new AND the label is comment because we show
    # this message in new comment email
    return if message.conversation.mailboxer_label_id == Mailboxer::Label::COMMENT.id
    @message      = message
    @conversation = message.conversation
    @admin        = receiver
    @structure    = @admin.structure
    @user         = message.sender
    if @conversation.mailboxer_label_id == Mailboxer::Label::INFORMATION.id
      mail to: @admin.email,
           subject: t('mailboxer.message_mailer.information_subject_new', sender: @user.name),
           template_name: 'new_information_message_email_to_admin'
    else
      mail to: @admin.email,
           subject: t('mailboxer.message_mailer.subject_new', sender: @user.name),
           template_name: 'new_message_email_to_admin'
    end
  end

  # Sends and email for indicating a reply in an already created conversation
  # User replying
  def reply_message_email_to_user(message, receiver)
    @message   = message
    @user      = receiver
    @structure = message.sender.try(:structure)

    @token   = @user.generate_and_set_reset_password_token if !@user.active?
    mail to: @user.email,
         subject: t('mailboxer.message_mailer.subject_reply', sender: @structure.name),
         template_name: 'reply_message_email_to_user'
  end

  def reply_message_email_to_admin(message, receiver)
    @message   = message
    @admin     = receiver
    @user      = message.sender
    mail to: @admin.email,
         subject: t('mailboxer.message_mailer.subject_reply', sender: @user.name),
         template_name: 'reply_message_email_to_admin'
  end
end
