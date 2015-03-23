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

  version :user_index_vertical do
    cloudinary_transformation transformation: [{ width: 450, crop: :scale }]
  end

  version :user_index_vertical_2x do
    cloudinary_transformation transformation: [{ width: 900, crop: :scale }]
  end

  version :user_index_horizontal_2x do
    cloudinary_transformation transformation: [{ width: 700, height: 500, crop: :fill }]
  end

  version :user_index_horizontal do
    cloudinary_transformation transformation: [{ width: 350, height: 250, crop: :fill }]
  end

  version :similar_article do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :fill }]
  end

  version :small do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :limit }]
  end

  version :very_small do
    cloudinary_transformation transformation: [{ width: 150, height: 120, crop: :limit }]
  end

end
