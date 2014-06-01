# encoding: utf-8
require 'rake/clean'

namespace :scheduler do
  namespace :admins do

    # Structure without logo neither description
    # $ rake scheduler:admins:send_reminder
    # Email sent on monday
    desc 'Send email to admins for inactivity'
    task :send_reminder => :environment do |t, args|
      if Time.now.monday?
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
        Structure.where{comments_count >= 5}.map(&:remind_for_widget)
      end
    end

  end
end
