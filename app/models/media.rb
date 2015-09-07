class Media < ActiveRecord::Base
  acts_as_paranoid

  FREE_PROFIL_LIMIT = 3

  self.table_name = 'medias'

  attr_accessible :mediable, :mediable_id, :mediable_type, :url, :caption, :format,
                  :provider_id, :provider_name, :thumbnail_url, :filepicker_url, :cover,
                  :star, :vertical_page_caption, :subject_ids, :remote_image_url

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :mediable, polymorphic: true, touch: true
  has_and_belongs_to_many :subjects

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :caption, length: { maximum: 255 }

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :images,       -> { where( type: "Media::Image" ) }
  scope :videos,       -> { where( type: "Media::Video" ) }
  scope :videos_first, -> { order('type DESC') }
  scope :images_first, -> { order('type ASC') }
  scope :cover,        -> { where( cover: true) }
  scope :cover_first,  -> { order('cover DESC NULLS LAST') }

  def url_html(options={})
    read_attribute(:url_html).try(:html_safe)
  end

  def video?
    self.type == 'Media::Video'
  end

  def image?
    self.type == 'Media::Image'
  end

  def thumbnail_url_html
    "<img src='#{self.thumbnail_url}' title='#{self.caption}' class='#{options[:class]}'/>".html_safe
  end

  def thumbnail_url
    if self.image.present?
      self.image.url(:thumbnail)
    elsif self.video?
      self.read_attribute(:thumbnail_url)
    else
      self.read_attribute(:url)
    end
  end

  def small_thumbnail_url
    if self.image.present?
      self.image.url(:small_thumbnail)
    elsif self.video?
      self.read_attribute(:thumbnail_url)
    else
      self.read_attribute(:url)
    end
  end

end
