# encoding: utf-8
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
# /!\ RESTART SERVER IF YOU WANT TO SEE YOUR CHANGES /!\
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
class VerticalPageImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: 'jpg'
  process quality: 'jpegmini:0'

  version :thumb do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :fill }], flags: :progressive
  end

  version :small do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :fill }], flags: :progressive
  end

  version :autocomplete do
    cloudinary_transformation transformation: [{ width: 80, height: 45, crop: :fill }], flags: :progressive
  end

  version :homepage do
    cloudinary_transformation transformation: [{ width: 1000, height: 500, crop: :fill }], flags: :progressive
  end

  version :search_page do
    cloudinary_transformation transformation: [{ width: 600, height: 500, crop: :fill }], flags: :progressive
  end

  version :large do
    cloudinary_transformation transformation: [{ width: 1600, height: 500, crop: :fill }], flags: :progressive
  end

end
