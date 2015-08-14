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

  version :thumbnail_email_cropped do
    process :crop_thumb_300_220
  end

  version :thumb do
    process :crop_thumb_200
  end

  version :small_thumb_100 do
    process :crop_thumb_100
  end

  version :small_thumb_85 do
    process :crop_thumb_85
  end

  version :small_thumb do
    process :crop_thumb_60
  end

  version :wide_and_blurry do
    cloudinary_transformation transformation: [{ width: 1024, height: 300, crop: :fill, effect: 'blur:900' }], flags: :progressive
  end

  private

  def crop_thumb_300_220
    custom_crop(300, 220)
  end

  def crop_thumb_200
    custom_crop(200)
  end

  def crop_thumb_100
    custom_crop(100)
  end

  def crop_thumb_85
    custom_crop(85)
  end

  def crop_thumb_60
    custom_crop(60)
  end

  def custom_crop(width, height=nil)
    height ||= width
    transformations = []
    crop_width      = (model.crop_width.to_i == 0 ? 600 : model.crop_width.to_i)
    transformations << { x: model.crop_x, y: model.crop_y, width: crop_width, height: crop_width, crop: :crop }
    transformations << { width: width, height: height, crop: :fill }
    { transformation: transformations }
  end
end
