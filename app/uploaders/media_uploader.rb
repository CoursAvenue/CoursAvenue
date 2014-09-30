# encoding: utf-8
class MediaUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: "jpg"
  cloudinary_transformation :transformation => [{  width: 1600, height: 1600, crop: :limit }]
  # process resize_to_fit: [1600]

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Create different versions of your uploaded files:
  version :original do
    process resize_to_fit: [1000]
  end

  version :thumbnail do
    process resize_to_fit: [500]
    process quality: 70
  end

  version :thumbnail_cropped do
    process resize_to_fit: [450, 300]
    process quality: 70
  end
end
