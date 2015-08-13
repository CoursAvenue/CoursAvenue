class Media < ActiveRecord::Base
  acts_as_paranoid

  FREE_PROFIL_LIMIT = 3

  self.table_name = 'medias'

  attr_accessible :mediable, :mediable_id, :mediable_type, :url, :caption, :format,
                  :provider_id, :provider_name, :thumbnail_url, :filepicker_url, :cover,
                  :star, :vertical_page_caption, :subject_ids

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
  # Callbacks                                                          #
  ######################################################################
  after_destroy :index_structure
  after_create  :index_structure

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :images,       -> { where( type: "Media::Image" ) }
  scope :videos,       -> { where( type: "Media::Video" ) }
  scope :videos_first, -> { order('type DESC') }
  scope :images_first, -> { order('type ASC') }
  scope :cover,        -> { where( cover: true) }
  scope :cover_first,  -> { order('cover DESC NULLS LAST') }

  # ------------------------------------------------------------------------------------ Search attributes
  # :nocov:
  searchable do
    latlon :location, multiple: true do
      if self.mediable.is_a? Structure
        self.mediable.places.collect do |place|
          Sunspot::Util::Coordinates.new(place.latitude, place.longitude)
        end
      end
    end

    string :type

    boolean :star

    boolean :comments_count do
      self.mediable.comments_count if self.mediable.is_a? Structure
    end

    string :subject_slugs, multiple: true do
      if self.mediable.is_a? Structure
        subject_slugs = []
        if self.subjects.empty?
          self.mediable.subjects.uniq.each do |subject|
            subject_slugs << subject.root.slug
            subject_slugs << subject.slug
          end
        else
          self.subjects.uniq.each do |subject|
            subject_slugs << subject.root.slug
            subject_slugs << subject.slug
          end
        end
        subject_slugs.uniq
      end
    end
  end
  # :nocov:

  handle_asynchronously :solr_index, queue: 'index' unless Rails.env.test?

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

  private

  # Reindex structure because we keep track of its media count
  def index_structure
    self.mediable.delay.index if self.mediable and self.mediable.is_a? Structure
  end
end
