# encoding: utf-8
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
# /!\ RESTART SERVER IF YOU WANT TO SEE YOUR CHANGES /!\
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
class VerticalPageImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: 'jpg'

  version :thumb do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :fill }],
                              flags: :progressive, quality: 'jpegmini:0'
  end

  version :small do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :fill }],
                              flags: :progressive, quality: 'jpegmini:0'
  end

  version :autocomplete do
    cloudinary_transformation transformation: [{ width: 80, height: 45, crop: :fill }],
                              flags: :progressive, quality: 'jpegmini:0'
  end

  version :homepage do
    cloudinary_transformation transformation: [{ width: 1000, height: 500, crop: :fill }],
                              flags: :progressive, quality: 'jpegmini:0'
  end

  version :search_page do
    cloudinary_transformation transformation: [{ width: 600, height: 500, crop: :fill }],
                              flags: :progressive, quality: 'jpegmini:0'
  end

  version :large do
    cloudinary_transformation transformation: [{ width: 1600, height: 500, crop: :fill }],
                              flags: :progressive, quality: 'jpegmini:0'
  end

end
