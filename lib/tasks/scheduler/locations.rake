# encoding: utf-8

require 'rake/clean'

namespace :scheduler do

  # Remind students to go recommend
  # $ rake scheduler:fix_locations
  desc 'Fix location that does not have latitude and longitude'
  task :fix_locations => :environment do |t, args|
    Location.where{latitude == nil}.select{ |l| l.places.empty? }.map(&:destroy)
    Location.where{latitude == nil}.each do |location|
      location.geocode
      location.save
      sleep 1
    end

    Structure.where{latitude == nil}.each do |structure|
      structure.geocode
      structure.save
      sleep 1
    end
  end
end
