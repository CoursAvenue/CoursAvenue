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
        image.migrate_image_to_cloudinary
      end
    end

    task :export_logos, [:filename] => :environment do |t, args|
      bar    = ProgressBar.new Structure.count
      Structure.find_each do |structure|
        bar.increment!
        structure.migrate_logo_to_cloudinary
      end
    end
  end
end
