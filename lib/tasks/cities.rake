# encoding: utf-8

require 'rake/clean'
# require 'debugger'

desc 'Affect city to places'
task :affect_city_to_places, [:filename] => :environment do |t, args|
  Place.all.each do |place|
    place_zip_code = place.zip_code
    place.city = City.where{zip_code == place_zip_code}.first
    place.save
  end
end
