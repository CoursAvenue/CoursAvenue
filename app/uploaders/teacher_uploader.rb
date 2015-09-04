class TeacherUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: "jpg"

  version :normal do
    cloudinary_transformation transformation: [{ width: 150, crop: :fit }], flags: :progressive
  end

end
