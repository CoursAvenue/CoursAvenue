class Flyer < ActiveRecord::Base
  mount_uploader :image, FlyerUploader

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :image, :treated

  ######################################################################
  # Scopes                                                             #
  ######################################################################

  default_scope           { order('created_at DESC') }
  scope :treated,      -> { where(treated: true) }
  scope :not_treated,  -> { where(treated: false) }
end
