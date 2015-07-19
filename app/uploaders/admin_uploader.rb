class AdminUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: "jpg"
  process resize_to_fit: [1600]

  version :default do
    cloudinary_transformation transformation: [{ width: 750, crop: :scale }], flags: :progressive
  end

  version :large do
    cloudinary_transformation transformation: [{ width: 1000, crop: :scale }], flags: :progressive
  end

  version :pro_index_double do
    cloudinary_transformation transformation: [{ width: 600, crop: :scale }], flags: :progressive
  end

  version :pro_index do
    cloudinary_transformation transformation: [{ width: 300, crop: :scale }], flags: :progressive
  end

  version :user_index_vertical do
    cloudinary_transformation transformation: [{ width: 450, crop: :scale }], flags: :progressive
  end

  version :user_index_vertical_2x do
    cloudinary_transformation transformation: [{ width: 900, crop: :scale }], flags: :progressive
  end

  version :user_index_horizontal_2x do
    cloudinary_transformation transformation: [{ width: 700, height: 500, crop: :fill }], flags: :progressive
  end

  version :user_index_horizontal do
    cloudinary_transformation transformation: [{ width: 350, height: 250, crop: :fill }], flags: :progressive
  end

  version :similar_article do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :fill }], flags: :progressive
  end

  version :small do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :limit }], flags: :progressive
  end

  version :very_small do
    cloudinary_transformation transformation: [{ width: 150, height: 120, crop: :limit }], flags: :progressive
  end
end
