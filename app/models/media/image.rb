class Media::Image < Media
  require 'open-uri'
  require 'aws'

  mount_uploader :c_image, MediaUploader

  has_attached_file :image,
                   styles: {
                     original: '1000x',
                     thumbnail: '500x',
                     thumbnail_cropped: '450x300#'
                    },
                    convert_options: { original: '-interlace Plane', thumbnail: '-interlace Plane', thumbnail_cropped: '-interlace Plane' }

  # validates_attachment_content_type :image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
  do_not_validate_attachment_file_type :image

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
    self.image.file_name
  end

  def url
    if self.image.present?
      self.image.url(:original)
    else
      self.read_attribute(:url)
    end
  end

  def thumbnail_url
    if self.image.present?
      self.image.url(:thumbnail)
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

  def migrate_image_to_cloudinary
    return unless self.image.present?
    cloudinary_uploaded_file = Cloudinary::Uploader.upload(self.image.url)
    self.update_column :c_image, "v#{cloudinary_uploaded_file['version']}/#{cloudinary_uploaded_file['public_id']}.#{cloudinary_uploaded_file['format']}"
  end

  private

  ######################################################################
  # Callbacs                                                           #
  ######################################################################
  def make_cover_if_first
    self.cover = true if self.mediable and self.mediable.medias.images.empty?
  end
end
