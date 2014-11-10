class Flyers < ActiveRecord::Base
  mount_uploader :image, FlyerUploader
end
