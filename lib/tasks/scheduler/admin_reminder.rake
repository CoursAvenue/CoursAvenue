# encoding: utf-8
require 'rake/clean'
require "#{Rails.root}/app/helpers/conversations_helper"
include ConversationsHelper

namespace :scheduler do
  namespace :admins do

    ######################################################################
    # For user requests                                                  #
    ######################################################################

    # Send email to admin if he has a user request not answered that is 1 day old
    # $ rake scheduler:admins:remind_for_user_requests_1
    desc 'Send email to admins who have user requests not answered'
    task :remind_for_user_requests_1 => :environment do |t, args|
      conversations = Mailboxer::Conversation.where( Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq(Mailboxer::Label::INFORMATION.id).and(
                                                     Mailboxer::Conversation.arel_table[:created_at].gteq(Date.today - 1.day).and(
                                                     Mailboxer::Conversation.arel_table[:created_at].lt(Date.today))) )
      conversations.each do |conversation|
        if conversation_waiting_for_reply?(conversation)
          admin = conversation.recipients.select{|recipient| recipient.is_a? Admin }.first
          next if admin.nil?
          AdminMailer.delay.message_information_reminder_1(conversation, admin)
        end
      end
    end

    # Send email to admin if he has a user request not answered that is 2 days old
    # $ rake scheduler:admins:remind_for_user_requests_2
    desc 'Send email to admins who have user requests not answered'
    task :remind_for_user_requests_2 => :environment do |t, args|
      conversations = Mailboxer::Conversation.where( Mailboxer::Conversation.arel_table[:mailboxer_label_id].eq(Mailboxer::Label::INFORMATION.id).and(
                                                     Mailboxer::Conversation.arel_table[:created_at].gteq(Date.today - 2.days).and(
                                                     Mailboxer::Conversation.arel_table[:created_at].lt(Date.today - 1.day))) )
      conversations.each do |conversation|
        if conversation_waiting_for_reply?(conversation)
          admin = conversation.recipients.select{|recipient| recipient.is_a? Admin }.first
          next if admin.nil?
          AdminMailer.delay.message_information_reminder_2(conversation, admin)
        end
      end
    end

    # Send email to admin when they don't have any visible courses
    # And the last visible course is from yesterday :
    # = The mail is sent when the last course perishes
    #     Dès qu'aucun cours / stage n'est affiché (dès que le dernier cours se périme)
    # $ rake scheduler:admins:check_if_courses_are_perished
    desc 'Send email to admins who have courses that have perished'
    task :check_if_courses_are_perished => :environment do |t, args|
      Structure.find_each do |structure|
        # Next if there is a published course
        next if structure.plannings.future.any?
        # # Next if there is courses in the future
        # next if structure.courses.where(Course.arel_table[:end_date].gteq(Date.today)).any?
        if structure.plannings.where(Planning.arel_table[:end_date].lt(Date.today).and(
                                  Planning.arel_table[:end_date].gteq(Date.yesterday)) ).any?
          structure.send(:update_intercom_status)
        end
      end
    end
  end
end
