# encoding: utf-8
class StructureLogoUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Create different versions of your uploaded files:
  version :original do
    process resize_to_fit: [600, 600]
  end

  version :large do
    cloudinary_transformation :transformation => [{  width: 450, height: 450, crop: :pad }]
    # process resize_to_fit: [450, 450]
  end

  version :thumb do
    cloudinary_transformation :transformation => [{  width: 200, height: 200, crop: :pad }]
    process :crop_thumb
  end

  version :small_thumb do
    cloudinary_transformation :transformation => [{  width: 60, height: 60, crop: :pad }]
    process :crop_small_thumb
  end

  # We don't add white list extension because we want to be able to add images from urls
  # that does not have extension, eg: http://filepicker.io/api/file/X8iSrLQESv27CTIXXHU1
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  private

  # Crop attributes are set with original (600x600) dimensions
  # That's why we use a ratio
  #
  # @return Hash
  def crop_thumb
    ratio = 600 / 200
    return { x: model.crop_x / ratio, y: model.crop_y / ratio, width: (model.crop_width || 600) / ratio, height: (model.crop_width || 600) / ratio, crop: :crop }
  end

  def crop_small_thumb
    ratio = 600 / 60
    return { x: model.crop_x / ratio, y: model.crop_y / ratio, width: (model.crop_width || 600) / ratio, height: (model.crop_width || 600) / ratio, crop: :crop }
  end
end
