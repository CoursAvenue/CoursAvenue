class Blog::Article < ActiveRecord::Base
  extend FriendlyId
  acts_as_paranoid

  friendly_id :title, use: [:slugged, :finders]

  acts_as_taggable_on :tags

  attr_accessible :title, :description, :content, :published, :subject_ids, :cover_image, :published_at

  has_and_belongs_to_many :subjects

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
  scope :published, -> { where.not( published: nil ) }

  private

  def set_published_at
    published_at ||= Time.now
  end
end
