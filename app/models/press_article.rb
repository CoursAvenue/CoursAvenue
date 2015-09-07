class PressArticle < ActiveRecord::Base

  attr_accessible :title, :url, :description, :published_at, :logo, :remote_logo_url

  mount_uploader :logo, PressArticleUploader

  default_scope -> { order('published_at DESC') }

end
