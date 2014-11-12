# encoding: utf-8

require 'rake/clean'

namespace :scheduler do
  namespace :users do
    include ConversationsHelper

    # $ rake scheduler:users:send_reminder
    # Email sent on monday
    desc 'Send email to admins for inactivity'
    task :send_reminder => :environment do |t, args|
      if Time.now.monday?
        User.active.all.map(&:send_reminder)
      end
    end

    # Remind users to go recommend
    # $ rake scheduler:users:resend_recommendation_stage_1
    desc 'Re ask users for recommendation'
    task :resend_recommendation_stage_1 => :environment do |t, args|
      UsersReminder.resend_recommendation_stage_1
    end

    # 2 days after last email sent
    # $ rake scheduler:users:resend_recommendation_stage_2
    desc 'Re ask users for recommendation'
    task :resend_recommendation_stage_2 => :environment do |t, args|
      UsersReminder.resend_recommendation_stage_2
    end

    # 1 year after a comment was written
    # $ rake scheduler:users:celebrate_comment_anniversary
    desc 'Re ask users for recommendation'
    task :celebrate_comment_anniversary => :environment do |t, args|
      date = 1.year.ago
      Comment::Review.where(created_at:  date.beginning_of_day..date.end_of_day).each do |comment|
        UserMailer.delay.comment_anniversary(comment)
      end
    end

    # Send email to user if he has sent a request to a structure and it is not answered since 2 days
    # $ rake scheduler:users:suggest_other_structures
    desc 'Send email to admins who have user requests not answered'
    task :suggest_other_structures => :environment do |t, args|
      conversations = Mailboxer::Conversation.where( Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq(Mailboxer::Label::INFORMATION.id).and(
                                                     Mailboxer::Conversation.arel_table[:created_at].gteq(Date.today - 2.days).and(
                                                     Mailboxer::Conversation.arel_table[:created_at].lt(Date.today - 1.day))) )
      conversations.each do |conversation|
        if conversation_waiting_for_reply?(conversation)
          user  = conversation.recipients.select{|recipient| recipient.is_a? User }.first
          admin = conversation.recipients.select{|recipient| recipient.is_a? Admin }.first
          next if user.nil? or admin.nil? or admin.structure.nil?
          UserMailer.delay.suggest_other_structures(user, admin.structure)
        end
      end
    end

    # Send a SMS to remind user of his/her class the following day.
    # $ rake scheduler:users:send_sms_reminder
    desc 'Send sms to users to remind them of their classes'
    task :send_sms_reminder => :environment do |t, args|
      users = ParticipationRequest.tomorrow.map(&:user).uniq
      users.each do |user|
        user.send_sms_reminder
      end
    end
  end
end
