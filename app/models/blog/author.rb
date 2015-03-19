class Blog::Author < ActiveRecord::Base

  attr_accessible :name, :description, :avatar, :remote_avatar_url

  has_many :articles, class_name: 'Blog::Article::ProArticle'

  mount_uploader :avatar, UserAvatarUploader

end
