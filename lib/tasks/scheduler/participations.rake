# encoding: utf-8

require 'rake/clean'

namespace :scheduler do
  namespace :participations do

    # $ rake scheduler:users:send_reminder
    # Email sent on monday
    desc 'Sends an email to participants one day later'
    task :send_reminder => :environment do |t, args|
      Participation.not_canceled.where{(created_at < Date.today) & (created_at > Date.yesterday)}.each do |participation|
        ParticipationMailer.delay.invite_friends_to_jpo(participation)
      end
    end
  end
end
