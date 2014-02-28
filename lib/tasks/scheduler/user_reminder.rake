# encoding: utf-8

require 'rake/clean'

namespace :scheduler do
  namespace :users do
    # Structure without logo neither description
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

    # 3 days after last email sent
    # $ rake scheduler:users:resend_recommendation_stage_3
    # desc 'Re ask users for recommendation'
    # task :resend_recommendation_stage_3 => :environment do |t, args|
    #   UsersReminder.resend_recommendation_stage_3
    # end
  end
end
