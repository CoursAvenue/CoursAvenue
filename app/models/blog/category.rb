class Blog::Category < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  attr_accessible :name, :page_title, :page_description, :description

  has_many :articles, class_name: 'Blog::Article'
end
