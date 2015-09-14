# encoding: utf-8

require 'rake/clean'

namespace :scheduler do
  namespace :participations do

    # $ rake scheduler:participations:send_reminder
    # Email sent the day after a participation has been made
    desc 'Sends an email to participants one day later'
    task :send_reminder => :environment do |t, args|
      # Participation.not_canceled.where{(created_at < Date.today) & (created_at > Date.yesterday)}.each do |participation|
      #   ParticipationMailer.delay(queue: 'mailers').invite_friends_to_jpo(participation)
      # end
    end
  end
end
