class FlyerUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave
end
