# encoding: utf-8

require 'rake/clean'

namespace :scheduler do

  # Remind students to go recommend
  # $ rake scheduler:resend_recommendation_stage_1
  desc 'Re ask students for recommendation'
  task :resend_recommendation_stage_1 => :environment do |t, args|
    StudentReminder.resend_recommendation_stage_1
  end

  # 2 days after last email sent
  # $ rake scheduler:resend_recommendation_stage_2
  # desc 'Re ask students for recommendation'
  # task :resend_recommendation_stage_2 => :environment do |t, args|
  #   StudentReminder.resend_recommendation_stage_2
  # end

  # 3 days after last email sent
  # $ rake scheduler:resend_recommendation_stage_3
  # desc 'Re ask students for recommendation'
  # task :resend_recommendation_stage_3 => :environment do |t, args|
  #   StudentReminder.resend_recommendation_stage_3
  # end
end
