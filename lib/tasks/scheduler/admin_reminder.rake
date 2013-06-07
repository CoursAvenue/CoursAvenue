# encoding: utf-8

require 'rake/clean'

namespace :scheduler do

  # Remind students to go recommend
  # $ rake scheduler:resend_recommendation_email_d_1
  desc 'Send email to admins for inactivity'
  task :resollicitate_admins_for_inactivity => :environment do |t, args|
    # Structure
    admins = Admin.joins{structure}.where{structure.updated_at > (Date.today - 3.days)}
  end

  # desc 'Send email to admins for inactivity'
  # task :resollicitate_admins_for_comments => :environment do |t, args|
  #   admins = Admin.joins{structure}.where{structure.updated_at > (Date.today - 3.days)}
  # end
end
