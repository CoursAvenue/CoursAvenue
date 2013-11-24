class DownloadMediaImages < ActiveRecord::Migration
  require 'open-uri'
  require 'RMagick'

  def up
    bar    = ProgressBar.new Media::Image.count
    amazon = AWS::S3.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
    bucket = amazon.buckets[ENV['AWS_BUCKET']]
    Media::Image.find_each do |image|
      bar.increment!
      begin
        # Original
        file          = open(image.url)
        object        = bucket.objects[image.s3_media_path + image.file_name]
        written_file  = object.write(file, acl: :public_read)
        new_image_url = written_file.public_url.to_s
        # Thumbnail
        file   = Magick::Image.read(image.url).first
        file   = file.resize_to_fit(500)

        # Writing file into S3 bucket
        object       = bucket.objects[image.s3_thumbnail_media_path + image.file_name]
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

  def down
  end
end
