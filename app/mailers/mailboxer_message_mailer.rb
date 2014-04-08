# encoding: utf-8
class MailboxerMessageMailer < ActionMailer::Base
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
    subject      = message.subject.to_s
    subject      = strip_tags(subject) unless subject.html_safe?

    @token       = @user.generate_and_set_reset_password_token if !@user.active?

    mail to: @user.email,
         subject: t('mailboxer.message_mailer.subject_new', sender: @structure.name),
         template_name: 'new_message_email_to_user'
  end

  def new_message_email_to_admin(message, receiver)
    @message   = message
    @admin     = receiver
    @user      = message.sender
    subject    = message.subject.to_s
    subject    = strip_tags(subject) unless subject.html_safe?
    mail to: @admin.email,
         subject: t('mailboxer.message_mailer.subject_new', sender: @user.name),
         template_name: 'new_message_email_to_admin'
  end

  # Sends and email for indicating a reply in an already created conversation
  # User replying
  def reply_message_email_to_user(message, receiver)
    @message   = message
    @user      = receiver
    subject    = message.subject.to_s
    subject    = strip_tags(subject) unless subject.html_safe?
    @structure = message.sender.try(:structure)

    @token   = @user.generate_and_set_reset_password_token if !@user.active?
    mail to: @user.email,
         subject: t('mailboxer.message_mailer.subject_reply', sender: message.sender.name),
         template_name: 'reply_message_email_to_user'
  end

  def reply_message_email_to_admin(message, receiver)
    @message   = message
    @admin     = receiver
    @user      = message.sender
    subject    = message.subject.to_s
    subject    = strip_tags(subject) unless subject.html_safe?
    mail to: @admin.email,
         subject: t('mailboxer.message_mailer.subject_reply', sender: @user.name),
         template_name: 'reply_message_email_to_admin'
  end
end
