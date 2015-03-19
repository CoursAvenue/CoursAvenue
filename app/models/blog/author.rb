class Blog::Author < ActiveRecord::Base

  attr_accessible :name, :description

  has_many :articles, class_name: 'Blog::Article::ProArticle'

end
