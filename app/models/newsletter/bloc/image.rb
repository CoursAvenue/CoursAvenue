class Newsletter::Bloc::Image < Newsletter::Bloc
  mount_uploader :image, NewsletterImageUploader
end
