class UserAvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::ImageOptimizer
  include Cloudinary::CarrierWave

  cloudinary_transformation transformation: [{ width: 800, height: 800, crop: :limit }]
  process :optimize

  def default_url
    ActionController::Base.helpers.asset_path("avatars/" + [version_name, "missing.png"].compact.join('/'))
  end

  version :wide do
    process resize_to_fill: [800, 800]
  end

  version :normal do
    process resize_to_fill: [450, 450]
  end

  version :thumb do
    process resize_to_fill: [200, 200]
  end

  version :small do
    process resize_to_fill: [100, 100]
  end

  version :small_thumb do
    process resize_to_fill: [100, 100]
  end

  version :mini do
    process resize_to_fill: [40, 40]
  end
end
