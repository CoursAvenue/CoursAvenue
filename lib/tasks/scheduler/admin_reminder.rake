# encoding: utf-8

require 'rake/clean'

namespace :scheduler do

  # Structure without logo neither description
  # $ rake scheduler:send_reminder
  desc 'Send email to admins for inactivity'
  task :send_reminder => :environment do |t, args|
    if Time.now.monday?
      Structure.all.map(&:send_reminder)
    end
  end

end
