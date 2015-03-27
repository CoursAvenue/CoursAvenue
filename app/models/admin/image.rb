class Admin::Image < ActiveRecord::Base
  mount_uploader :image, AdminUploader

  def url
    image.url
  end

  def small
    image.small.url
  end
end
