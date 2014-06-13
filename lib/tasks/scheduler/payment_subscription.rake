# encoding: utf-8

require 'rake/clean'

namespace :scheduler do

  # Remind students to go recommend
  # $ rake scheduler:payment_subscription
  desc 'Reprocess payment for subscription plan that are expired but not canceled'
  task :payment_subscription => :environment do |t, args|
    SubscriptionPlan.where(SubscriptionPlan.arel_table[:canceled_at].eq(nil).and(
                           SubscriptionPlan.arel_table[:expires_at].eq(Date.today))).each do |subscription_plan|

      subscription_plan.renew!
    end
  end
end
