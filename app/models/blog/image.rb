class Blog::Image < ActiveRecord::Base
  mount_uploader :image, BlogImageUploader
end
