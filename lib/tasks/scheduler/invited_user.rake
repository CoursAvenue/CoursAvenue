# encoding: utf-8

require 'rake/clean'

namespace :scheduler do
  namespace :invited_users do

    # Invitations to teachers
    namespace :teachers do
      # Remind students to go recommend
      # $ rake scheduler:invited_users:teachers:resend_invitation_stage_1
      desc 'Re ask invited teachers'
      task :resend_invitation_stage_1 => :environment do |t, args|
        invited_teachers = InvitedUser::Teacher.where(InvitedUser::Teacher.arel_table[:invitation_for].eq(nil).and(
                                                      InvitedUser::Teacher.arel_table[:registered].eq(false).and(
                                                      InvitedUser::Teacher.arel_table[:updated_at].lt(Date.today - 3.days).and(
                                                      InvitedUser::Teacher.arel_table[:email_status].eq(nil)))) )
        invited_teachers.each{ |invited_teacher| invited_teacher.send_invitation_stage_1 }
      end

      # 2 days after last email sent
      # $ rake scheduler:invited_users:teachers:resend_invitation_stage_2
      desc 'Re re ask invited teachers'
      task :resend_invitation_stage_2 => :environment do |t, args|
        invited_teachers = InvitedUser::Teacher.where(InvitedUser::Teacher.arel_table[:invitation_for].eq(nil).and(
                                                      InvitedUser::Teacher.arel_table[:registered].eq(false).and(
                                                      InvitedUser::Teacher.arel_table[:updated_at].gteq(Date.today - 4.days).and(
                                                      InvitedUser::Teacher.arel_table[:updated_at].lt(Date.today - 3.days).and(
                                                      InvitedUser::Teacher.arel_table[:email_status].eq('resend_stage_1'))))) )
        invited_teachers.each{ |invited_teacher| invited_teacher.send_invitation_stage_2 }
      end
    end

    # Invitations to users
    namespace :students do
      # Remind students to go recommend
      # $ rake scheduler:invited_users:students:resend_invitation_stage_1
      desc 'Re ask invited teachers'
      task :resend_invitation_stage_1 => :environment do |t, args|
        invited_students = InvitedUser::Student.where(InvitedUser::Student.arel_table[:invitation_for].eq(nil).and(
                                                      InvitedUser::Student.arel_table[:registered].eq(false).and(
                                                      InvitedUser::Student.arel_table[:updated_at].lt(Date.today - 3.days).and(
                                                      InvitedUser::Student.arel_table[:email_status].eq(nil)))) )
        invited_students.each{ |invited_student| invited_student.send_invitation_stage_1 }
      end

      # 2 days after last email sent
      # $ rake scheduler:invited_users:students:resend_invitation_stage_2
      desc 'Re re ask invited teachers'
      task :resend_invitation_stage_2 => :environment do |t, args|
        invited_students = InvitedUser::Student.where(InvitedUser::Student.arel_table[:invitation_for].eq(nil).and(
                                                      InvitedUser::Student.arel_table[:registered].eq(false).and(
                                                      InvitedUser::Student.arel_table[:updated_at].gteq(Date.today - 4.days).and(
                                                      InvitedUser::Student.arel_table[:updated_at].lt(Date.today - 3.days).and(
                                                      InvitedUser::Student.arel_table[:email_status].eq('resend_stage_1'))))) )
        invited_students.each{ |invited_student| invited_student.send_invitation_stage_2 }
      end
    end

    # Invitations to JPO
    namespace :jpo do
      # Remind students to go recommend
      # $ rake scheduler:invited_users:jpo:resend_invitation_stage_1
      # desc 'Re ask invited teachers'
      # task :resend_invitation_stage_1 => :environment do |t, args|
      #   # Using registered method instead of boolean because it's more specific than
      #   invited_users = InvitedUser::Student.where{(invitation_for == 'jpo') & (updated_at < Date.today - 3.days) & (email_status == nil)}.reject(&:registered?)
      #   invited_users.each{ |invited_user| invited_user.send_invitation_stage_1 }
      # end

      # # 2 days after last email sent
      # # $ rake scheduler:invited_users:jpo:resend_invitation_stage_2
      # desc 'Re re ask invited teachers'
      # task :resend_invitation_stage_2 => :environment do |t, args|
      #   invited_users = InvitedUser::Student.where{(invitation_for == 'jpo') & (updated_at >= Date.today - 4.days) & (updated_at < Date.today - 3.days) & (email_status == 'resend_stage_1')}.reject(&:registered?)
      #   invited_users.each{ |invited_user| invited_user.send_invitation_stage_2 }
      # end
    end
  end
end
