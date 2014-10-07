# encoding: utf-8
require 'rake/clean'

namespace :scheduler do
  namespace :discovery_pass do

    # $ rake scheduler:discovery_pass:five_days_before_renewal
    # Email sent the day after a participation has been made
    desc 'Send email to admins who have user requests not answered'
    task :five_days_before_renewal => :environment do |t, args|
      DiscoveryPass.not_canceled.expires_in_five_days.each do |subscription_plan|
        DiscoveryPassMailer.delay.five_days_before_renewal(subscription_plan)
      end
    end
  end
end
