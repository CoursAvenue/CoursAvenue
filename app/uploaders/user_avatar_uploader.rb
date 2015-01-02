class UserAvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::ImageOptimizer
  include CarrierWave::Compatibility::Paperclip
  include Cloudinary::CarrierWave
end
