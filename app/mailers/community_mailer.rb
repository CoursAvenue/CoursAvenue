class CommunityMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  default from: 'CoursAvenue <hello@coursavenue.com>'

  def notify_member_of_question(user, message, thread)
    @user       = user
    @message    = message
    @thread     = thread
    @membership = @thread.community.memberships.where(user_id: @user.id).first
    @structure  = @thread.community.structure
    @sender     = @thread.messages.order('created_at ASC').first.sender
    set_global_variables

    mail to: @user.email,
      subject: I18n.t('community.emails.notify_member_of_question', { structure_name: @structure.name }),
      reply_to: generate_reply_to(@user)
  end

  def notify_admin_of_question(admin, message, thread)
    return if admin.nil?
    @admin     = admin
    @message   = message
    @thread    = thread
    @structure = @thread.community.structure
    @sender    = @thread.messages.order('created_at ASC').first.sender
    set_global_variables

    mail to: @admin.email,
      subject: I18n.t('community.emails.notify_admin_of_question'),
      reply_to: generate_reply_to(@admin)
  end

  def notify_answer_from_teacher(user, message, thread)
    @user      = user
    @message   = message
    @thread    = thread
    @sender    = @thread.messages.order('created_at ASC').first.sender
    @structure = @thread.community.structure
    set_global_variables

    mail to: @user.email,
      subject: I18n.t('community.emails.notify_answer_from_teacher', { structure_name: @structure.name }),
      reply_to: generate_reply_to(@user)
  end

  def notify_answer_from_member(user, message, thread)
    @user      = user
    @message   = message
    @thread    = thread
    @sender    = @thread.messages.order('created_at ASC').last.sender
    @structure = @thread.community.structure
    set_global_variables

    mail to: @user.email,
      subject: I18n.t('community.emails.notify_answer_from_member', { structure_name: @structure.name }),
      reply_to: generate_reply_to(@user)
  end

  def notify_answer_from_member_to_teacher(admin, message, thread)
    return if admin.nil?
    @admin     = admin
    @message   = message
    @thread    = thread
    @sender    = @thread.messages.order('created_at ASC').last.sender
    @structure = @thread.community.structure
    set_global_variables

    mail to: @admin.email,
      subject: I18n.t('community.emails.notify_answer_from_member_to_teacher', { sender_name: @sender.name }),
      reply_to: generate_reply_to(@admin)
  end

  private

  def set_global_variables
    @community = @thread.community
    @structure = @community.structure
  end

  # Generate a reply_to address using the ReplyToken.
  # Replies are handled by the EmailProcessor class.
  #
  # @return a string, the reply to email address.
  def generate_reply_to(sender)
    @token = ReplyToken.create(reply_type: 'community')
    @token.data = {
      sender_type: sender.class.to_s.downcase,
      sender_id: sender.id,
      thread_id: @thread.id,
    }
    @token.save

    @token.email_address
  end
end
