# encoding: utf-8
require 'rake/clean'
include ConversationsHelper

namespace :scheduler do
  namespace :participation_requests do

    ######################################################################
    # For Participation requests                                         #
    ######################################################################
    # Send email to admin if he has a user request not answered that is 1 day old
    # $ rake scheduler:admins:remind_for_participation_requests_1
    desc 'Send email to admins who have user requests not answered'
    task :remind_for_participation_requests_1 => :environment do |t, args|
      participation_requests = ParticipationRequest.where( ParticipationRequest.arel_table[:created_at].gteq(Date.today - 1.day).and(
                                                           ParticipationRequest.arel_table[:created_at].lt(Date.today)) )
      participation_requests.each do |participation_request|
        if participation_request.pending? and participation_request.last_modified_by == 'User'
          ParticipationRequestMailer.delay.participation_request(participation_request)
        end
      end
    end

    # Send email to admin if he has a user request not answered that is 2 days old
    # $ rake scheduler:admins:remind_for_participation_requests_2
    desc 'Send email to admins who have user requests not answered'
    task :remind_for_participation_requests_2 => :environment do |t, args|
      participation_requests = ParticipationRequest.where( ParticipationRequest.arel_table[:created_at].gteq(Date.today - 2.days).and(
                                                           ParticipationRequest.arel_table[:created_at].lt(Date.today - 1.day)) )
      participation_requests.each do |participation_request|
        if participation_request.pending? and participation_request.last_modified_by == 'User'
          ParticipationRequestMailer.delay.participation_request(participation_request)
        end
      end
    end

    # Send email to admin if he has a user request not answered that is 2 days old
    # $ rake scheduler:admins:remind_for_participation_requests_2
    desc 'Send email to admins who have user requests not answered'
    task :how_did_the_course_went => :environment do |t, args|
      participation_requests = ParticipationRequest.accepted.where( ParticipationRequest.arel_table[:date].gteq(Date.today - 1.days).and(
                                                                    ParticipationRequest.arel_table[:date].lt(Date.today - 2.day)) )
      participation_requests.each do |participation_request|
        if participation_request.pending? and participation_request.last_modified_by == 'User'
          ParticipationRequestMailer.delay.participation_request(participation_request)
        end
      end
    end

    # Send email to admin if he has a user request not answered that is 2 days old
    # $ rake scheduler:admins:remind_for_participation_requests_2
    desc 'Send email to admins who have user requests not answered'
    task :recap => :environment do |t, args|
      participation_requests = ParticipationRequest.accepted.where( ParticipationRequest.arel_table[:date].gteq(Date.tomorrow).and(
                                                                    ParticipationRequest.arel_table[:date].lt(Date.tomorrow + 1.day)) )
      # Group request
      participation_requests.group_by(&:structure).each do |structure, participation_requests|
        ParticipationRequestMailer.delay.recap_for_teacher(structure, participation_requests)
      end
    end
  end
end
