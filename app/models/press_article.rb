class PressArticle < ActiveRecord::Base

  attr_accessible :title, :url, :description, :published_at, :logo, :remote_logo_url

  mount_uploader :logo, PressArticleUploader

  # TODO: delete after deploy
  has_attached_file :old_logo,
                    styles: { original: '300x' },
                    convert_options: { original: '-interlace Plane' }


  default_scope -> { order('published_at DESC') }

end
