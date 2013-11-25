class MigratingCourseAndProfilePictureToMedias < ActiveRecord::Migration
  require 'open-uri'
  require 'RMagick'

  def up
    bar = ProgressBar.new (Structure.count + Course.count)

    [Structure, Course].each do |model|
      model.find_each do |instance|
        bar.increment!
        if instance.image.present?
          begin
            # Original
            if instance.is_a? Structure
              media = Media::Image.new(mediable: instance)
            else
              media = Media::Image.new(mediable: instance.structure)
            end
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
          rescue Exception => exception
            puts exception.message
            exception.backtrace.each { |line| puts line }

            puts "Url not working: #{media.mediable.slug} / #{media.url}"
          end
        end
      end
    end
  end

  def down
  end
end
