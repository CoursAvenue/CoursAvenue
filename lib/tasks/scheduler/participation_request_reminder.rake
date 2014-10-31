# encoding: utf-8
require 'rake/clean'
include ConversationsHelper

namespace :scheduler do
  namespace :participation_requests do

    ######################################################################
    # For Participation requests                                         #
    ######################################################################
    # Send email to admin if he has a user request not answered that is 1 day old
    # $ rake scheduler:participation_requests:remind_admin_for_participation_requests_1
    desc 'Send email to admins who have user requests not answered'
    task :remind_admin_for_participation_requests_1 => :environment do |t, args|
      participation_requests = ParticipationRequest.pending.where( ParticipationRequest.arel_table[:created_at].gteq(Date.today - 1.day).and(
                                                                   ParticipationRequest.arel_table[:created_at].lt(Date.today).and(
                                                                   ParticipationRequest.arel_table[:last_modified_by].eq('User'))) )
      participation_requests.each do |participation_request|
        ParticipationRequestMailer.delay.you_received_a_request_stage_1(participation_request)
      end
    end

    # Send email to admin if he has a user request not answered that is 2 days old
    # $ rake scheduler:participation_requests:remind_admin_for_participation_requests_2
    desc 'Send email to admins who have user requests not answered'
    task :remind_admin_for_participation_requests_2 => :environment do |t, args|
      participation_requests = ParticipationRequest.pending.where( ParticipationRequest.arel_table[:created_at].gteq(Date.today - 2.days).and(
                                                                   ParticipationRequest.arel_table[:created_at].lt(Date.today - 1.day).and(
                                                                   ParticipationRequest.arel_table[:last_modified_by].eq('User'))) )
      participation_requests.each do |participation_request|
        ParticipationRequestMailer.delay.you_received_a_request_stage_2(participation_request)
      end
    end

    # Send email to user if he has a user request not answered that is 1 day old
    # $ rake scheduler:participation_requests:remind_user_for_participation_requests_1
    desc 'Send email to user who have pending requests'
    task :remind_user_for_participation_requests_1 => :environment do |t, args|
      participation_requests = ParticipationRequest.pending.where( ParticipationRequest.arel_table[:updated_at].gteq(Date.today - 1.day).and(
                                                                   ParticipationRequest.arel_table[:updated_at].lt(Date.today).and(
                                                                   ParticipationRequest.arel_table[:last_modified_by].eq('Structure'))) )
      participation_requests.each do |participation_request|
        ParticipationRequestMailer.delay.request_has_been_modified_by_teacher_to_user_stage_1(participation_request)
      end
    end

    # Send email to user if he has a user request not answered that is 2 days old
    # $ rake scheduler:participation_requests:remind_user_for_participation_requests_2
    desc 'Send email to user who have pending requests'
    task :remind_user_for_participation_requests_2 => :environment do |t, args|
      participation_requests = ParticipationRequest.pending.where( ParticipationRequest.arel_table[:updated_at].gteq(Date.today - 2.days).and(
                                                                   ParticipationRequest.arel_table[:updated_at].lt(Date.today - 1.day).and(
                                                                   ParticipationRequest.arel_table[:last_modified_by].eq('Structure'))) )
      participation_requests.each do |participation_request|
        ParticipationRequestMailer.delay.request_has_been_modified_by_teacher_to_user_stage_2(participation_request)
      end
    end

    # Send email to admin day after
    # $ rake scheduler:participation_requests:how_was_the_student
    desc 'Send email to admins who had students coming to their courses'
    task :how_was_the_student => :environment do |t, args|
      participation_requests = ParticipationRequest.accepted.where( ParticipationRequest.arel_table[:date].eq(Date.yesterday) )
      participation_requests.each do |participation_request|
        ParticipationRequestMailer.delay.how_was_the_student(participation_request)
      end
    end

    # Send a recap email to admin who have requests tomorrow
    # $ rake scheduler:participation_requests:recap
    desc 'Send email to admins who have user requests not answered'
    task :recap_for_teacher => :environment do |t, args|
      participation_requests = ParticipationRequest.accepted.where( ParticipationRequest.arel_table[:date].eq(Date.tomorrow))
      # Group request
      participation_requests.group_by(&:structure).each do |structure, participation_requests|
        ParticipationRequestMailer.delay.recap_for_teacher(structure, participation_requests)
      end
    end

    ######################################################################
    # COMMENTS                                                           #
    ######################################################################

    # Send email to users that had been to courses
    # $ rake scheduler:participation_requests:how_was_the_trial
    desc 'Send email to users who took a trial course and did not leave a comment'
    task :how_was_the_trial => :environment do |t, args|
      participation_requests = ParticipationRequest.accepted.where( ParticipationRequest.arel_table[:date].eq(Date.yesterday) )

      # Group request
      participation_requests.each do |participation_request|
        ParticipationRequestMailer.delay.how_was_the_trial(participation_request)
      end
    end

    # Send email to users that had been to courses
    # $ rake scheduler:participation_requests:how_was_the_trial_stage_1
    desc 'Send email to users who took a trial course and did not leave a comment after five day'
    task :how_was_the_trial_stage_1 => :environment do |t, args|
      participation_requests = ParticipationRequest.accepted.where( ParticipationRequest.arel_table[:date].eq(5.days.from_now) )

      # Group request
      participation_requests.each do |participation_request|
        if !participation_request.user.has_left_a_review_on? participation_request.structure
          ParticipationRequestMailer.delay.how_was_the_trial_stage_1(participation_request)
        end
      end
    end

    # Send email to users that had been to courses
    # $ rake scheduler:participation_requests:how_was_the_trial_stage_2
    desc 'Send email to users who took a trial course and did not leave a comment after five day'
    task :how_was_the_trial_stage_2 => :environment do |t, args|
      participation_requests = ParticipationRequest.accepted.where( ParticipationRequest.arel_table[:date].eq(10.days.from_now) )

      # Group request
      participation_requests.each do |participation_request|
        if !participation_request.user.has_left_a_review_on? participation_request.structure
          ParticipationRequestMailer.delay.how_was_the_trial_stage_1(participation_request)
        end
      end
    end
  end
end
