class NewsletterImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: "jpg"

  # Create different versions of your uploaded files:
  version :newsletter_body do
    cloudinary_transformation transformation: [{ width: 600, crop: :scale }]
  end

end
