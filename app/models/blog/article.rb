class Blog::Article < ActiveRecord::Base
  extend FriendlyId
  acts_as_paranoid

  friendly_id :title, use: [:slugged, :finders, :history]

  acts_as_taggable_on :tags

  attr_accessible :page_title, :title, :description, :content, :published, :subject_ids, :published_at,
                  :tag_list, :category_id, :page_description, :type, :remote_image_url, :author_id,
                  :box_top, :box_bottom

  ######################################################################
  # Relations                                                          #
  ######################################################################
  has_and_belongs_to_many :subjects
  has_many :medias, as: :mediable
  belongs_to :author, class_name: 'Blog::Author'

  mount_uploader :image, BlogImageUploader

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :set_published_at

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :published              , -> { where( published: true ) }
  scope :ordered_by_views       , -> { order('page_views DESC') }
  scope :ordered_by_publish_date, -> { order('published_at DESC') }

  def self.searchable_language
    'french'
  end

  def published_at
    if read_attribute(:published_at).nil?
      self.created_at
    else
      read_attribute(:published_at)
    end
  end

  def pro_article?
    false
  end

  def increment_page_views!
    self.update_column :page_views, self.page_views + 1
  end

  private

  def set_published_at
    published_at ||= Time.now
    self.save
  end

  def should_generate_new_friendly_id?
    return (!published? or self.slug.nil?)
  end

end
