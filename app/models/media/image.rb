class Media::Image < Media
  require 'open-uri'
  require 'aws'

  ######################################################################
  # Callbacs                                                           #
  ######################################################################
  before_create :make_cover_if_first
  after_create :save_thumbnail_url_to_s3
  after_destroy :remove_file_from_s3

  def video?
    false
  end

  def image?
    true
  end

  # Returns formatted url in html of the file
  # Not in a helper to mimic auto_html gem used before.
  # Options
  #   lazy: do not put src attribute, puts it in the data-original attribute for
  #   lazy.js
  #
  # @return String html of the image
  def url_html(options={})
    if options[:lazy]
      "<img data-original='#{self.thumbnail_url}' title='#{self.caption}'/>".html_safe
    else
      "<img src='#{self.url}' title='#{self.caption}'/>".html_safe
    end
  end

  # Returns file name based on url
  #
  # @return String name of the file
  def file_name
    self.url.split('/').last
  end

  # Path of the media path on S3
  #
  # @return String path of the S3 media
  def s3_media_path
    "medias/#{self.mediable_type.downcase.pluralize}/#{self.mediable_id}/originals/"
  end

  # Path of the thumbnail media path on S3
  #
  # @return String thumbnail path S3 media
  def s3_thumbnail_media_path
    "medias/#{self.mediable_type.downcase.pluralize}/#{self.mediable_id}/thumbnails/"
  end

  private

  ######################################################################
  # Callbacs                                                           #
  ######################################################################
  def make_cover_if_first
    self.cover = true if self.mediable.medias.images.empty?
  end

  # Create a thumbnail and saves it to S3
  #
  # @return nil
  def save_thumbnail_url_to_s3
    if self.filepicker_url
      convert_options = {
        fit: 'clip',
        h:500,
        w:500
      }
      file = open("#{self.filepicker_url}/convert?#{convert_options.to_query}")

      # Writing file into S3 bucket
      object = CoursAvenue::Application::S3_BUCKET.objects[s3_thumbnail_media_path + file_name]
      written_file = object.write(file, acl: :public_read) # :authenticated_read
      self.update_column :thumbnail_url, written_file.public_url.to_s
    end
    nil
  end

  # Remove file from S3 after destroy
  #
  # @return [type] [description]
  def remove_file_from_s3
    if self.thumbnail_url
      thumbnail_image = CoursAvenue::Application::S3_BUCKET.objects[URI.unescape(self.thumbnail_url.split('.com/').last)]
      thumbnail_image.delete
    end
    if self.url
      original_image  = CoursAvenue::Application::S3_BUCKET.objects[URI.unescape(self.url.split('.com/').last)]
      original_image.delete
    end
  end
end
