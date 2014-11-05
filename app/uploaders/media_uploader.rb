# encoding: utf-8
class MediaUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: "jpg"
  cloudinary_transformation :transformation => [{  width: 1600, height: 1600, crop: :limit }]
  # process resize_to_fit: [1600]

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    ActionController::Base.helpers.asset_path("images/" + [version_name, "missing.png"].compact.join('/'))
  end

  # Create different versions of your uploaded files:
  version :original do
    cloudinary_transformation :transformation => [{  width: 1000, height: 1000, crop: :limit }]
  end

  version :thumbnail do
    cloudinary_transformation :transformation => [{  width: 500, height: 500, crop: :limit }]
    process quality: 70
  end

  version :thumbnail_cropped do
    process resize_to_fit: [450, 300]
    process quality: 70
  end

  version :thumbnail_email_cropped do
    cloudinary_transformation :transformation => [
        { width: 300, height: 220, crop: :fill },
        { overlay: "essai-gratuit", width: 184, height: 35, gravity: :south_east, y: 20 }
      ]

    process quality: 70
  end
end

