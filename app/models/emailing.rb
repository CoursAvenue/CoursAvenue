class Emailing < ActiveRecord::Base

  attr_accessible :title, :body, :header_image

  # TODO: Change the values.
  has_attached_file :header_image,
                    styles: { large: '600x' },
                    convert_options: { large: '-interlace Plane' }

  validates :title, presence: true
  validates :body, presence: true
  validates_attachment_content_type :header_image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
end
