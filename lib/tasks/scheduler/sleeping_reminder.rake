# encoding: utf-8
require 'rake/clean'
include ConversationsHelper

namespace :scheduler do
  namespace :sleepings do

    # Structure without logo neither description
    # $ rake scheduler:admins:send_reminder
    # Email sent on monday
    desc 'Send email to sleepings structure for them to take control'
    task :take_control => :environment do |t, args|
      Structure.where(active: true).each do |structure|
        return if !structure.is_sleeping
        AdminMailer.delay.take_control_of_your_account(structure)
        if structure.other_emails.present?
          structure.other_emails.split(';').each do |email|
            next if email == structure.contact_email
            AdminMailer.delay.take_control_of_your_account(structure, email)
          end
        end
      end
    end
  end
end
