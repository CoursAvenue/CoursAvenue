class PressArticleUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: "jpg"

  version :original do
    cloudinary_transformation transformation: [{ width: 300, crop: :fit }], flags: :progressive
  end

end
