# encoding: utf-8
require 'rake/clean'
include ConversationsHelper

namespace :scheduler do
  namespace :sleepings do

    # Structure without logo neither description
    # Email sent every 10 days
    # $ rake scheduler:sleepings:take_control
    desc 'Send email to sleepings structure for them to take control'
    task :take_control => :environment do |t, args|
      next if (Date.today.yday % 10) != 0
      Structure.where(active: true).each do |structure|
        next if !structure.is_sleeping
        AdminMailer.delay(queue: 'mailers').take_control_of_your_account(structure)
        if structure.other_emails.present?
          structure.other_emails.split(';').each do |email|
            next if email == structure.contact_email
            AdminMailer.delay(queue: 'mailers').take_control_of_your_account(structure, email)
          end
        end
      end
    end

    # $ rake scheduler:sleepings:wake_up
    desc 'Wake up activated sleeping structures'
    task :wake_up => :environment do |t, args|
      structures_to_wake_up = Structure.where(Structure.arel_table[:active].eq(false)).select do |structure|
        (structure.admins.any? and structure.admins.first.confirmed? and structure.admins.first.created_at > 2.days.ago)
      end
      structures_to_wake_up.map(&:wake_up!)
    end
  end
end
