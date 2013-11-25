class Media::Image < Media
  require 'open-uri'
  require 'aws'

  after_create :save_thumbnail_url_to_s3
  after_destroy :remove_file_from_s3

  def video?
    false
  end

  def image?
    true
  end

  def url_html(options={})
    "<img src='#{self.url}' title='#{self.caption}'/>".html_safe
  end

  def file_name
    self.url.split('/').last
  end

  def s3_media_path
    "medias/#{self.mediable_type.downcase.pluralize}/#{self.mediable_id}/originals/"
  end

  def s3_thumbnail_media_path
    "medias/#{self.mediable_type.downcase.pluralize}/#{self.mediable_id}/thumbnails/"
  end

  private

  def save_thumbnail_url_to_s3
    convert_options = {
      fit: 'clip',
      h:500,
      w:500
    }
    file   = open("#{self.filepicker_url}/convert?#{convert_options.to_query}")

    # Writing file into S3 bucket
    object = CoursAvenue::Application::S3_BUCKET.objects[s3_thumbnail_media_path + file_name]
    written_file = object.write(file, acl: :public_read) # :authenticated_read
    self.update_column :thumbnail_url, written_file.public_url.to_s
  end

  def remove_file_from_s3
    if self.thumbnail_url
      thumbnail_image = CoursAvenue::Application::S3_BUCKET.objects[self.thumbnail_url.split('.com/').last] if self.thumbnail_url
      thumbnail_image.delete
    end
    if self.url
      original_image  = CoursAvenue::Application::S3_BUCKET.objects[self.url.split('.com/').last]
      original_image.delete
    end
  end
end
