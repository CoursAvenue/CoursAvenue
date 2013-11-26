class Media < ActiveRecord::Base
  acts_as_paranoid

  self.table_name = 'medias'

  attr_accessible :mediable, :mediable_id, :mediable_type, :url, :caption, :format,
                  :provider_id, :provider_name, :thumbnail_url, :filepicker_url, :cover

  belongs_to :mediable, polymorphic: true

  validates :url, presence: true
  validates :caption, length: { maximum: 255 }

  scope :images,       -> { where(type: "Media::Image") }
  scope :videos,       -> { where(type: "Media::Video") }
  scope :videos_first, -> { order('type DESC NULLS LAST') }
  scope :cover,        -> { where{cover == true} }
  scope :cover_first,  -> { order('cover DESC NULLS LAST') }


  def video?
    self.type == 'Media::Video'
  end

  def image?
    self.type == 'Media::Image'
  end

  def thumbnail_url_html(options={})
    "<img src='#{self.thumbnail_url}' title='#{self.caption}'/>".html_safe
  end

end
