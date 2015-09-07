class Teacher < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :structure
  has_many   :plannings
  has_many   :courses, through: :plannings

  attr_reader :delete_image
  attr_accessible :name, :description, :image, :structure_id, :remote_image_url,
                  :old_image

  mount_uploader :image, TeacherUploader

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name, presence: true

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  default_scope -> { order('name ASC') }

end
