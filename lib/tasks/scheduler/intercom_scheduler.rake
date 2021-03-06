# encoding: utf-8
require 'rake/clean'

namespace :scheduler do
  namespace :intercom do

    # Send email if Subscription is on seven day trial
    # $ rake scheduler:intercom:subscription_on_seventh_day_trial
    desc 'Updates Intercom status of admins'
    task :subscription_on_seventh_day_trial => :environment do |t, args|
      Subscription.where(trial_ends_at: 7.days.from_now.beginning_of_day..7.days.from_now.end_of_day).each do |subscription|
        SuperAdminMailer.delay(queue: 'mailers').alert_for_seven_days_trial(subscription)
      end
    end

    # Send email if Subscription is on seven day trial
    # $ rake scheduler:intercom:subscription_on_second_day_activation
    desc 'Updates Intercom status of admins'
    task :subscription_on_second_day_activation => :environment do |t, args|
      Subscription.where(charged_at: 2.days.ago.beginning_of_day..2.days.ago.end_of_day).each do |subscription|
        SuperAdminMailer.delay(queue: 'mailers').alert_for_second_day_after_charged(subscription)
      end
    end
  end
end
