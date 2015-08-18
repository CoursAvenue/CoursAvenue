class Media::Image < Media
  require 'open-uri'
  require 'aws'

  mount_uploader :image, MediaUploader

  ######################################################################
  # Callbacs                                                           #
  ######################################################################
  before_create :make_cover_if_first

  def video?
    false
  end

  def image?
    true
  end

  # Returns formatted url in html of the file
  #
  # @return String html of the image
  def url_html(options={})
    "<img src='#{self.url}' title='#{self.caption}'/>".html_safe
  end

  # Returns file name based on url
  #
  # @return String name of the file
  def file_name
    self.image.file_name
  end

  def url(version = :original)
    if self.image.present?
      self.image.url(version)
    else
      self.read_attribute(:url)
    end
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

  def update_image
    return if self.image.present?
    self.image = URI.parse(self.read_attribute(:url))
    self.save
  end

  def reprocess_thumbnail_cropped
    return if self.image.exists?(:thumbnail_cropped)
    self.image.reprocess! :thumbnail_cropped
  end

  private

  ######################################################################
  # Callbacs                                                           #
  ######################################################################
  def make_cover_if_first
    self.cover = true if self.mediable and self.mediable.medias.images.empty?
  end
end
