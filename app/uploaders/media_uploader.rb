# encoding: utf-8
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
# /!\ RESTART SERVER IF YOU WANT TO SEE YOUR CHANGES /!\
# /!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\/!\
class MediaUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: "jpg"
  process resize_to_fit: [1600]

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    ActionController::Base.helpers.asset_path("images/" + [version_name, "missing.png"].compact.join('/'))
  end

  # Create different versions of your uploaded files:
  version :original do
    cloudinary_transformation transformation: [{ width: 750, height: 750, crop: :limit },
                                               { overlay: 'watermark', width: 150, gravity: :south_east, y: 5, x: 10 }], flags: :progressive
  end

  version :search_thumbnail do
    cloudinary_transformation transformation: [{ width: 250, height: 100, crop: :fill }], flags: :progressive
    process quality: 70
  end

  version :thumbnail do
    cloudinary_transformation transformation: [{ width: 500, height: 500, crop: :limit },
                                               { overlay: 'watermark', width: 100, gravity: :south_east, y: 5, x: 10 }], flags: :progressive
    process quality: 70
  end

  version :small_thumbnail do
    cloudinary_transformation transformation: [{ width: 70, height: 70, crop: :limit }], flags: :progressive
    process quality: 70
  end

  version :thumbnail_cropped do
    cloudinary_transformation transformation: [{ width: 450, height: 300, crop: :fit },
                                               { overlay: 'watermark', width: 100, gravity: :south_east, y: 5, x: 10 }], flags: :progressive
    process quality: 70
  end

  version :thumbnail_email_cropped do
    process :thumbnail_email_cropped
    process quality: 70
  end

  version :wide_and_blurry do
    cloudinary_transformation transformation: [{ width: 1024, height: 300, crop: :fill, effect: 'blur:900' }], flags: :progressive
  end

  version :thumbnail_blurry do
    cloudinary_transformation transformation: [{ width: 300, height: 200, crop: :fill, effect: 'blur:900' }], flags: :progressive
  end

  version :gallery do
    cloudinary_transformation transformation: [{ width: 400, crop: :fill }], flags: :progressive
  end

  version :redactor do
    cloudinary_transformation transformation: [{ width: 250, height: 200, crop: :limit }], flags: :progressive
  end

  private

  def thumbnail_email_cropped
    transformations = []
    transformations << { width: 300, height: 220, crop: :fill }
    if model.mediable.is_open_for_trial?
      transformations << { overlay: "essai-gratuit", width: 184, height: 35, gravity: :south_east, y: 20 }
    elsif model.mediable.has_promotion?
      transformations << { overlay: "promotion", width: 167, height: 35, gravity: :south_east, y: 20 }
    else
      transformations << { overlay: "decouvrir", width: 167, height: 35, gravity: :south_east, y: 20 }
    end
    { transformation: transformations }
  end
end

