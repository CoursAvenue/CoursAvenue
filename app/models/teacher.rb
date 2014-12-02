class Teacher < ActiveRecord::Base
  acts_as_paranoid

  ######################################################################
  # Relations                                                          #
  ######################################################################
  belongs_to :structure
  has_many   :plannings
  has_many   :courses, through: :plannings

  attr_reader :delete_image
  attr_accessible :name, :description, :image, :structure_id

  has_attached_file :image,
                     styles: { normal: '150x' },
                     default_url: ActionController::Base.helpers.asset_path('avatars/original/missing.png'),
                     processors: [:thumbnail, :paperclip_optimizer]

  validates_attachment_content_type :image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validates :name, presence: true

  ######################################################################
  # Scopes                                                             #
  ######################################################################
  default_scope -> { order('name ASC') }

end
