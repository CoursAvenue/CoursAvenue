# encoding: utf-8

require 'rake/clean'

namespace :scheduler do
  namespace :users do
    include ConversationsHelper

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
        UserMailer.delay(queue: 'mailers').comment_anniversary(comment)
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
