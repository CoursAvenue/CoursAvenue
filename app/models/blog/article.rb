class Blog::Article < ActiveRecord::Base
  extend FriendlyId
  acts_as_paranoid

  friendly_id :title_with_date, use: [:slugged, :finders]

  acts_as_taggable_on :tags

  attr_accessible :title, :description, :content, :published, :subject_ids, :cover_image, :published_at,
                  :tag_list

  has_and_belongs_to_many :subjects

  validates :title, :description, :content, :published_at, presence: true
  has_attached_file :cover_image,
                    styles: { default: '900×600#', small: '250x200#'}
  validates_attachment_content_type :cover_image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  ######################################################################
  # Callbacks                                                          #
  ######################################################################
  after_create :set_published_at

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  scope :published, -> { where( published: true ) }

  private

  def set_published_at
    published_at ||= Time.now
  end

  def title_with_date
    [title, (published_at ? I18n.l(published_at, format: :date_short) : nil)]
  end

  def should_generate_new_friendly_id?
    return (!published? or self.slug.nil? or (self.created_at > Time.now - 1.day))
  end

end
