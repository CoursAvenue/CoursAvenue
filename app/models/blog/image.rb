class Blog::Image < ActiveRecord::Base
  mount_uploader :image, BlogImageUploader

  def url
    image.url
  end

  def small
    image.small.url
  end
end
