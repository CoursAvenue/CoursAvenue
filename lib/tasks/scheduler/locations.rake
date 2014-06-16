# encoding: utf-8

require 'rake/clean'

namespace :scheduler do

  # Remind students to go recommend
  # $ rake scheduler:fix_locations
  desc 'Fix place that does not have latitude and longitude'
  task :fix_locations => :environment do |t, args|
    Place.where{latitude == nil}.select{ |l| l.places.empty? }.map(&:destroy)
    Place.where{latitude == nil}.each do |place|
      place.geocode
      place.save(validate: false)
      sleep 1
    end

    Structure.where{latitude == nil}.each do |structure|
      structure.geocode
      structure.save(validate: false)
      sleep 1
    end
  end
end
