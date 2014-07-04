# encoding: utf-8
require 'rake/clean'

namespace :scheduler do
  namespace :admins do

    # Structure without logo neither description
    # $ rake scheduler:admins:send_reminder
    # Email sent on monday
    desc 'Send email to admins for inactivity'
    task :send_reminder => :environment do |t, args|
      if (Time.now.cweek % 2 == 0) and Time.now.monday?
        Structure.all.map(&:send_reminder)
      end
    end

    # Email sent on thursday
    # $ rake scheduler:admins:remind_for_pending_comments
    desc 'Send email to admins that have pending comments'
    task :remind_for_pending_comments => :environment do |t, args|
      if Time.now.thursday?
        Comment::Review.pending.map(&:structure).uniq.map(&:remind_for_pending_comments)
      end
    end

    # Email sent on thursday
    # $ rake scheduler:admins:remind_for_widget
    desc 'Send email to admins that have access to the widget'
    task :remind_for_widget => :environment do |t, args|
      if Time.now.thursday?
        Structure.where(Structure.arel_table[:comments_count].gteq(5)).map(&:remind_for_widget)
      end
    end

    # Email sent on thursday
    # $ rake scheduler:admins:remind_for_widget
    desc 'Send email to admins that have access to the widget'
    task :remind_for_widget => :environment do |t, args|
      if Time.now.thursday?
        Structure.find_each(&:remind_for_planning_outdated)
      end
    end

    ######################################################################
    # For premium users                                                  #
    ######################################################################

    # Send email if account expires in 15 days
    # $ rake scheduler:admins:remind_for_premium_expiration_15
    desc 'Send email to admins that have access to the widget'
    task :remind_for_premium_expiration_15 => :environment do |t, args|
      SubscriptionPlan.expires_in_fifteen_days.not_monthly.each do |subscription_plan|
        AdminMailer.delay.fifteen_days_to_end_of_subscription(subscription_plan)
      end
    end

    # Send email if account expires in 5 days
    # $ rake scheduler:admins:remind_for_premium_expiration_5
    desc 'Send email to admins that have access to the widget'
    task :remind_for_premium_expiration_5 => :environment do |t, args|
      SubscriptionPlan.expires_in_five_days.each do |subscription_plan|
        AdminMailer.delay.five_days_to_end_of_subscription(subscription_plan)
      end
    end

  end
end
