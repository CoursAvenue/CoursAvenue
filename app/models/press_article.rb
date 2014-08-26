class PressArticle < ActiveRecord::Base

  attr_accessible :title, :url, :description, :published_at, :logo

  has_attached_file :logo,
                    styles: { original: { geometry: '300x' } }
  validates_attachment_content_type :logo, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  default_scope -> { order('published_at DESC') }

end
