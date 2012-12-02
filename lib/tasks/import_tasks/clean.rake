# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
# require 'debugger'

namespace :import do
  desc 'Cleaning all the tables'
  task :clean => :environment do |t, args|
    puts 'Cleaning DB'
    CourseGroup.delete_all
    Course.delete_all
    Discipline.delete_all
    Planning.delete_all
    Price.delete_all
    RentingRoom.delete_all
    Structure.delete_all
  end
end
