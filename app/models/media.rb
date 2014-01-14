class Media < ActiveRecord::Base
  acts_as_paranoid

  self.table_name = 'medias'

  attr_accessible :mediable, :mediable_id, :mediable_type, :url, :caption, :format,
                  :provider_id, :provider_name, :thumbnail_url, :filepicker_url, :cover, :star, :vertical_page_caption

  belongs_to :mediable, polymorphic: true

  validates :url, presence: true
  validates :caption, length: { maximum: 255 }

  scope :images,       -> { where(type: "Media::Image") }
  scope :videos,       -> { where(type: "Media::Video") }
  scope :videos_first, -> { order('type DESC, cover DESC NULLS LAST') }
  scope :cover,        -> { where{cover == true} }
  scope :cover_first,  -> { order('cover DESC NULLS LAST') }

  # ------------------------------------------------------------------------------------ Search attributes
  searchable do
    latlon :location, multiple: true do
      self.mediable.locations.collect do |location|
        Sunspot::Util::Coordinates.new(location.latitude, location.longitude)
      end
    end

    string :type

    boolean :star

    boolean :comments_count do
      self.mediable.comments_count
    end

    string :subject_slugs, multiple: true do
      subject_slugs = []
      self.mediable.subjects.uniq.each do |subject|
        subject_slugs << subject.slug
        subject_slugs << subject.root.slug if subject.root
      end
      subject_slugs.uniq
    end
  end

  def url_html(options={})
    read_attribute(:url_html).html_safe
  end

  def video?
    self.type == 'Media::Video'
  end

  def image?
    self.type == 'Media::Image'
  end

  def thumbnail_url_html(options={})
    if options[:lazy]
      "<img data-original='#{self.thumbnail_url}' title='#{self.caption}' class='#{options[:class]}'/>".html_safe
    else
      "<img src='#{self.thumbnail_url}' title='#{self.caption}' class='#{options[:class]}'/>".html_safe
    end
  end

end
