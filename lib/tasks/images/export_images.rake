# encoding: utf-8

require 'rake/clean'
require 'csv'

namespace :images do

  desc 'Move medias'
  task :export_medias, [:filename] => :environment do |t, args|
    bar    = ProgressBar.new Media::Image.count
    Media::Image.find_each do |image|
      bar.increment!
      begin
        # Original
        file          = open(image.url)
        object        = CoursAvenue::Application::S3_BUCKET.objects[image.s3_media_path + image.file_name]
        written_file  = object.write(file, acl: :public_read)
        new_image_url = written_file.public_url.to_s
        # Thumbnail
        # file   = Magick::Image.read(image.url).first
        # Hack taken from: http://stackoverflow.com/questions/9479960/rmagick-imagemagick-gives-error-no-decode-delegate-for-this-image-format
        # Which prevents RMagick from not finding the good format
        rmagick_image = Magick::ImageList.new
        bin           = file.read
        rmagick_image = rmagick_image.from_blob(bin)
        file          = rmagick_image.resize_to_fit(500)

        # Writing file into S3 bucket
        object       = CoursAvenue::Application::S3_BUCKET.objects[image.s3_thumbnail_media_path + image.file_name]
        file         = StringIO.open(file.to_blob)
        written_file = object.write(file, acl: :public_read) # :authenticated_read

        image.update_column :url, new_image_url
        image.update_column :thumbnail_url, written_file.public_url.to_s
      rescue Exception => exception
        puts exception.message
        exception.backtrace.each { |line| puts line }

        puts "Url not working: #{image.mediable.slug} / #{image.url}"
      end
    end
  end
  # Use rake images:export
  desc 'Move course and structures images to medias'
  task :export, [:filename] => :environment do |t, args|
    bar = ProgressBar.new (Structure.count + Course.count)

    [Structure, Course].each do |model|
      model.find_each do |instance|
        bar.increment!
        if instance.image.present?
          if instance.is_a? Structure
            media = Media::Image.new(mediable: instance, cover: true)
          else
            media = Media::Image.new(mediable: instance.structure)
          end
          begin
            # Original
            file          = open(instance.image.url)
            object        = CoursAvenue::Application::S3_BUCKET.objects[media.s3_media_path + instance.image_file_name]
            written_file  = object.write(file, acl: :public_read)
            new_image_url = written_file.public_url.to_s
            # Thumbnail
            # file   = Magick::Image.read(image.url).first
            # Hack taken from: http://stackoverflow.com/questions/9479960/rmagick-imagemagick-gives-error-no-decode-delegate-for-this-image-format
            # Which prevents RMagick from not finding the good format
            rmagick_image = Magick::ImageList.new
            bin           = file.read
            rmagick_image = rmagick_image.from_blob(bin)
            file          = rmagick_image.resize_to_fit(500)

            # Writing file into S3 bucket
            object       = CoursAvenue::Application::S3_BUCKET.objects[media.s3_thumbnail_media_path + instance.image_file_name]
            file         = StringIO.open(file.to_blob)
            written_file = object.write(file, acl: :public_read) # :authenticated_read

            media.url           = URI.unescape(new_image_url)
            media.thumbnail_url = URI.unescape(written_file.public_url.to_s)
            media.save

            if instance.is_a? Structure
              puts "Structure: #{instance.id};#{URI.unescape(new_image_url)};#{URI.unescape(written_file.public_url.to_s)}"
            else
              puts "Course: #{instance.id};#{URI.unescape(new_image_url)};#{URI.unescape(written_file.public_url.to_s)}"
            end
          rescue Exception => exception
            puts exception.message
            exception.backtrace.each { |line| puts line }

            puts "Url not working: #{instance.slug} / #{instance.image.url}"
          end
        end
      end
    end
  end
end
