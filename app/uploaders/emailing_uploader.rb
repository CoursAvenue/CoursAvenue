class EmailingUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: "jpg"

  version :large do
    cloudinary_transformation transformation: [{ width: 600, crop: :fit }], flags: :progressive
  end

end
