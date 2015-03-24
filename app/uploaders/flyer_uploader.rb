class FlyerUploader < CarrierWave::Uploader::Base
  include CarrierWave::ImageOptimizer
  include Cloudinary::CarrierWave
  process :optimize
end
