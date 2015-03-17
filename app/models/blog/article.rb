class Blog::Article < ActiveRecord::Base
  extend FriendlyId
  acts_as_paranoid

  friendly_id :title_with_date, use: [:slugged, :finders]

  acts_as_taggable_on :tags

  attr_accessible :page_title, :title, :description, :content, :published, :subject_ids, :cover_image, :published_at,
                  :tag_list, :category_id, :page_description

  has_and_belongs_to_many :subjects
  belongs_to :category, class_name: 'Blog::Category', foreign_key: :category_id

  has_attached_file :cover_image,
                    styles: { default: '750x', small: '250x200#', very_small: '150x120#' },
                    convert_options: { default: '-interlace Plane', small: '-interlace Plane', very_small: '-interlace Plane' },
                    processors: [:thumbnail, :paperclip_optimizer]

  validates_attachment_content_type :cover_image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :set_published_at

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :published, -> { where( published: true ) }
  default_scope -> { order('published_at DESC') }

  def published_at
    if read_attribute(:published_at).nil?
      self.created_at
    else
      read_attribute(:published_at)
    end
  end

  # Return similar articles
  def similar_articles(limit = 2)
    articles = Blog::Article.published.tagged_with(self.tags).take(limit)
    articles += Blog::Article.order('RANDOM()').take(limit - articles.length + 1)
    articles.reject { |article| article.id == self.id }.uniq.take(limit)
  end

  private

  def set_published_at
    published_at ||= Time.now
    self.save
  end

  def title_with_date
    [title, (published_at ? I18n.l(published_at, format: :date_short) : nil)]
  end

  def should_generate_new_friendly_id?
    return (!published? or self.slug.nil? or (self.created_at > Time.now - 1.day))
  end

end
