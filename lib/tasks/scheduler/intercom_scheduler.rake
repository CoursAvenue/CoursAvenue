# encoding: utf-8
require 'rake/clean'

namespace :scheduler do
  namespace :intercom do

    # $ rake scheduler:intercom:update_intercom_page_view_attribute
    desc 'Updates Intercom status of admins'
    task :update_intercom_page_view_attribute => :environment do |t, args|
      intercom = Intercom::Client.new(app_id: ENV['INTERCOM_APP_ID'], api_key: ENV['INTERCOM_API_KEY'])
      # Less than a day ago because Intercom data will update itself when user logs in
      Admin.where(Admin.arel_table[:current_sign_in_at].gt(1.month.ago).and(
                  Admin.arel_table[:current_sign_in_at].lt(1.day.ago))).find_each do |admin|
        next if admin.structure.nil?
        intercom_user = intercom.users.find(:user_id => "Admin_#{admin.id}")
        intercom_user.custom_attributes['# vue planning'] = admin.structure.planning_page_views_nb
        intercom.users.save(intercom_user)
      end
    end

    # Send email if Subscription is on seven day trial
    # $ rake scheduler:intercom:subscription_on_seventh_day_trial
    desc 'Updates Intercom status of admins'
    task :subscription_on_seventh_day_trial => :environment do |t, args|
      Subscription.where(trial_ends_at: 7.days.from_now.beginning_of_day..7.days.from_now.end_of_day).each do |subscription|
        SuperAdminMailer.delay.alert_for_seven_days_trial(subscription)
      end
    end

    # Send email if Subscription is on seven day trial
    # $ rake scheduler:intercom:subscription_on_second_day_activation
    desc 'Updates Intercom status of admins'
    task :subscription_on_second_day_activation => :environment do |t, args|
      Subscription.where(charged_at: 2.days.ago.beginning_of_day..2.days.ago.end_of_day).each do |subscription|
        SuperAdminMailer.delay.alert_for_second_day_after_charged(subscription)
      end
    end
  end
end
