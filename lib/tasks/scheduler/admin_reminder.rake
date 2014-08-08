# encoding: utf-8
require 'rake/clean'
require "#{Rails.root}/app/helpers/conversations_helper"
include ConversationsHelper

namespace :scheduler do
  namespace :admins do

    # Structure without logo neither description
    # $ rake scheduler:admins:send_reminder
    # Email sent on monday
    desc 'Send email to admins for inactivity'
    task :send_reminder => :environment do |t, args|
      if (Date.today.cweek % 2 == 1) and Time.now.monday?
        Structure.all.map(&:send_reminder)
      end
    end

    # Email sent on thursday
    # $ rake scheduler:admins:remind_for_pending_comments
    desc 'Send email to admins that have pending comments'
    task :remind_for_pending_comments => :environment do |t, args|
      if Time.now.wednesday?
        Comment::Review.pending.map(&:structure).uniq.map(&:remind_for_pending_comments)
      end
    end

    # Email sent on thursday
    # $ rake scheduler:admins:remind_for_widget
    desc 'Send email to admins that have access to the widget'
    task :remind_for_widget => :environment do |t, args|
      if Time.now.friday?
        Structure.where(Structure.arel_table[:comments_count].gteq(5)).map(&:remind_for_widget)
      end
    end

    # Email sent on thursday
    # $ rake scheduler:admins:remind_for_planning_outdated
    desc 'Send email to admins that have access to the widget'
    task :remind_for_planning_outdated => :environment do |t, args|
      if Time.now.thursday?
        Structure.find_each(&:remind_for_planning_outdated)
      end
    end

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
          AdminMailer.delay.message_information_reminder_2(conversation, admin)
        end
      end
    end

    # Send email to admin when they don't have any visible courses
    # And the last visible course is from yesterday :
    # = The mail is sent when the last course perishes
    #     Dès qu'aucun cours / stage n'est affiché (dès que le dernier cours se périme)
    # $ rake scheduler:admins:check_if_courses_are_perished
    desc 'Send email to admins who have user requests not answered'
    task :check_if_courses_are_perished => :environment do |t, args|
      Structure.find_each do |structure|
        # Next if there is a published course
        next if self.courses.without_open_courses.detect(&:is_published?)
        # # Next if there is courses in the future
        # next if structure.courses.where(Course.arel_table[:end_date].gteq(Date.today)).any?
        if structure.plannings.where(Planning.arel_table[:end_date].lt(Date.today).and(
                                  Planning.arel_table[:end_date].gteq(Date.yesterday)) ).any?
          AdminMailer.delay.no_more_active_courses(structure)
        end
      end
    end

    ######################################################################
    # For premium users                                                  #
    ######################################################################

    # Send email if account expires in 15 days
    # $ rake scheduler:admins:remind_for_premium_expiration_15
    desc 'Send email to admins that have access to the widget'
    task :remind_for_premium_expiration_15 => :environment do |t, args|
      SubscriptionPlan.expires_in_fifteen_days.not_monthly.each do |subscription_plan|
        AdminMailer.delay.fifteen_days_to_end_of_subscription(subscription_plan)
      end
    end

    # Send email if account expires in 5 days
    # $ rake scheduler:admins:remind_for_premium_expiration_5
    desc 'Send email to admins that have access to the widget'
    task :remind_for_premium_expiration_5 => :environment do |t, args|
      SubscriptionPlan.expires_in_five_days.each do |subscription_plan|
        AdminMailer.delay.five_days_to_end_of_subscription(subscription_plan)
      end
    end
  end
end
