# encoding: utf-8

require 'rake/clean'

namespace :scheduler do

  # Remind students to go recommend
  # $ rake scheduler:resend_invitation_stage_1
  desc 'Re re ask invited teachers'
  task :resend_invitation_stage_1 => :environment do |t, args|
    invited_teachers = InvitedTeacher.where{(registered == false) & (updated_at < Date.today - 3.days) & (email_status == nil)}
    invited_teachers.each{ |invited_teacher| invited_teacher.send_invitation_stage_1 }
  end

  # 2 days after last email sent
  # $ rake scheduler:resend_invitation_stage_2
  desc 'Re re ask invited teachers'
  task :resend_invitation_stage_2 => :environment do |t, args|
    invited_teachers = InvitedTeacher.where{(registered == false) & (updated_at >= Date.today - 4.days) & (updated_at < Date.today - 3.days) & (email_status == 'resend_stage_1')}
    invited_teachers.each{ |invited_teacher| invited_teacher.send_invitation_stage_2 }
  end

  # 3 days after last email sent
  # $ rake scheduler:resend_invitation_stage_3
  # desc 'Re ask students for recommendation'
  # task :resend_invitation_stage_3 => :environment do |t, args|
  #   StudentReminder.resend_invitation_stage_3
  # end
end
