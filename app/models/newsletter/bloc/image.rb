class Newsletter::Bloc::Image < Newsletter::Bloc
  mount_uploader :image, NewsletterImageUploader

  attr_accessible :remote_image_url, :image
end
