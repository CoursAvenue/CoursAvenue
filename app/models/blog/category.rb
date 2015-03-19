class Blog::Category < ActiveRecord::Base
  extend FriendlyId

  COLORS = %w(dark-blue orange yellow red green)

  friendly_id :name, use: [:slugged, :finders]

  acts_as_tree cache_depth: true, touch: true

  attr_accessible :name, :page_title, :page_description, :description, :type,
                  :ancestry, :parent, :color, :subtitle, :position, :image, :remote_image_url

  mount_uploader :image, BlogImageUploader

  has_many :articles, class_name: 'Blog::Article'

  def pro_category?
    false
  end
end
