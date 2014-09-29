# encoding: utf-8

require 'rake/clean'
require 'csv'

namespace :images do
  namespace :cloudinary do
    desc 'Move medias'
    task :export_medias, [:filename] => :environment do |t, args|
      bar    = ProgressBar.new Media::Image.count
      Media::Image.find_each do |image|
        bar.increment!
        begin
          image.c_image = open(image.url)
          image.save
        rescue Exception => exception
          puts exception.message
          exception.backtrace.each { |line| puts line }
          puts "Url not working: #{image.mediable.slug} / #{image.url}"
        end
      end
    end

    task :export_logos, [:filename] => :environment do |t, args|
      bar    = ProgressBar.new Structure.count
      Structure.find_each do |structure|
        bar.increment!
        next unless structure.logo.present?
        begin
          structure.c_logo = open(structure.logo.url)
          structure.save
        rescue Exception => exception
          puts exception.message
          exception.backtrace.each { |line| puts line }
          puts "Url not working: #{structure.slug} / #{structure.logo.url}"
        end
      end
    end
  end
end
