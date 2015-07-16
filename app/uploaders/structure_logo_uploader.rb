# encoding: utf-8
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
# /!\ RESTART SERVER IF YOU WANT TO SEE YOUR CHANGES /!\
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
class StructureLogoUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    ActionController::Base.helpers.asset_path("logos/" + [version_name, "missing.png"].compact.join('/'))
  end

  cloudinary_transformation transformation: [{  width: 600, height: 600, crop: :pad }]
  process convert: "jpg"

  # Create different versions of your uploaded files:
  version :original do
    process resize_to_fit: [600, 600]
  end

  version :large do
    # cloudinary_transformation transformation: [{  width: 450, height: 450, crop: :pad }]
    process resize_to_fit: [450, 450]
  end

  version :thumb do
    process crop_thumb: [200]
  end

  version :small_thumb do
    process crop_thumb: [60]
  end

  version :small_thumb_85 do
    process crop_thumb: [85]
  end

  version :small_thumb_120 do
    process crop_thumb: [120]
  end

  version :thumbnail_email_cropped do
    process crop_thumb: [300, 220]
  end

  version :wide_and_blurry do
    cloudinary_transformation transformation: [{ width: 1024, height: 300, crop: :fill, effect: 'blur:900' }]
  end

  # We don't add white list extension because we want to be able to add images from urls
  # that does not have extension, eg: http://filepicker.io/api/file/X8iSrLQESv27CTIXXHU1
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  private

  def crop_thumb(width, height=nil)
    height ||= width
    transformations = []
    crop_width      = (model.crop_width.to_i == 0 ? 600 : model.crop_width.to_i)
    transformations << { x: model.crop_x, y: model.crop_y, width: crop_width, height: crop_width, crop: :crop }
    transformations << { width: width, height: height, crop: :fill }
    { transformation: transformations }
  end
end
