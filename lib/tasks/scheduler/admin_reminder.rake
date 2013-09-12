# encoding: utf-8

require 'rake/clean'

namespace :scheduler do

  # Structure without logo neither description
  # $ rake scheduler:resollicitate_admins_for_inactivity
  desc 'Send email to admins for inactivity'
  task :profile_empty => :environment do |t, args|
    Structure.all.map(&:send_reminder)
  end

end
