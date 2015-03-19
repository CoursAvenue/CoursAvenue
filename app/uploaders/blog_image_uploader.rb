# encoding: utf-8
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
# /!\ RESTART SERVER IF YOU WANT TO SEE YOUR CHANGES /!\
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
class BlogImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::ImageOptimizer
  include Cloudinary::CarrierWave

  process convert: "jpg"
  process resize_to_fit: [1600]

  version :default do
    cloudinary_transformation transformation: [{ width: 750, crop: :scale }]
  end

  version :large do
    cloudinary_transformation transformation: [{ width: 1000, crop: :scale }]
  end

  version :pro_index_double do
    cloudinary_transformation transformation: [{ width: 600, crop: :scale }]
  end

  version :pro_index do
    cloudinary_transformation transformation: [{ width: 300, crop: :scale }]
  end

  version :small do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :limit }]
  end

  version :very_small do
    cloudinary_transformation transformation: [{ width: 150, height: 120, crop: :limit }]
  end

end
