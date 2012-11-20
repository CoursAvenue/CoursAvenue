# encoding: utf-8

# Import all renting room and associate it to appropriate structure
require 'rake/clean'
require 'csv'
require 'debugger'

namespace :import do
  desc 'Cleaning all the tables'
  task :clean => :environment do |t, args|
    Structure.delete_all
    Discipline.delete_all
    Audience.delete_all
    Course.delete_all
  end
end
