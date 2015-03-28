# encoding: utf-8
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
# /!\ RESTART SERVER IF YOU WANT TO SEE YOUR CHANGES /!\
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
class VerticalPageImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::ImageOptimizer
  include Cloudinary::CarrierWave

  process convert: "jpg"

  version :thumb do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :fit }]
  end

  version :large do
    cloudinary_transformation transformation: [{ width: 1600, height: 500, crop: :fit }]
  end

end
