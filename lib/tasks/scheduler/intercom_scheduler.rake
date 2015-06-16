# encoding: utf-8
require 'rake/clean'

namespace :scheduler do
  namespace :intercom do

    # $ rake scheduler:intercom:update_intercom_page_view_attribute
    desc 'Updates Intercom status of admins'
    task :update_intercom_page_view_attribute => :environment do |t, args|
      intercom = IntercomClientFactory.client
      Admin.find_each do |admin|
        structure = admin.structure
        next if structure.nil?
        has_updated_plannings_recently = structure.plannings.where(Planning.arel_table[:updated_at].gt(1.month.ago)).any?
        has_signed_in_since_a_month = (admin.current_sign_in_at and admin.current_sign_in_at > 1.month.ago)
        next if structure.plannings.future.any? and !has_updated_plannings_recently and !has_signed_in_since_a_month
        intercom_user = intercom.users.find(:user_id => "Admin_#{admin.id}")
        # TODO
        intercom_user.custom_attributes['Stage à venir']   = structure.courses.trainings.flat_map{ |c| c.plannings.future }.length
        intercom_user.custom_attributes['Màj Cours < 30j'] = has_updated_plannings_recently
        intercom_user.custom_attributes['# vue planning']  = admin.structure.planning_page_views_nb
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
