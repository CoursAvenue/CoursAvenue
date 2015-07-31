class CommunityMailer < ActionMailer::Base
  include ::ActionMailerWithTextPart
  include Roadie::Rails::Automatic

  layout 'email'

  default from: 'CoursAvenue <hello@coursavenue.com>'

  def notify_member_of_question(user, message, thread)
    @user      = user
    @message   = message
    @thread    = thread
    set_global_variables

    mail to: @user.email,
      subject: 'notify_member_of_question',
      reply_to: generate_reply_to(@user)
  end

  def notify_admin_of_question(admin, message, thread)
    @admin     = admin
    @message   = message
    @thread    = thread
    set_global_variables

    mail to: @admin.email,
      subject: 'notify_admin_of_question',
      reply_to: generate_reply_to(@admin)
  end

  def notify_answer_from_teacher(user, message, thread)
    @user    = user
    @message = message
    @thread  = thread
    set_global_variables

    mail to: @user.email,
      subject: 'notify_answer_from_teacher',
      reply_to: generate_reply_to(@user)
  end

  def notify_answer_from_member(user, message, thread)
    @user    = user
    @message = message
    @thread  = thread
    set_global_variables

    mail to: @user.email,
      subject: 'notify_answer_from_member',
      reply_to: generate_reply_to(@user)
  end

  def notify_answer_from_member_to_teacher(admin, message, thread)
    @admin   = admin
    @message = message
    @thread  = thread
    set_global_variables

    mail to: @admin.email,
      subject: 'notify_answer_from_member_to_teacher',
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