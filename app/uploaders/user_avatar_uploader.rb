class UserAvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::ImageOptimizer
  include Cloudinary::CarrierWave
end
