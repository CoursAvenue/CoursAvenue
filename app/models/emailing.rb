class Emailing < ActiveRecord::Base

  SECTION_METADATA = [
    { title: 'Nom'          , action: :name },
    { title: "Nombre d'avis", action: :comments }, # TODO: => comments.count
    { title: 'À partir de',   action: :prices },   # TODO: => prices. ???
    { title: 'Villes',        action: :cities }
  ]

  attr_accessible :title, :body, :header_image, :section_metadata_one, :section_metadata_two, :section_metadata_three, :emailing_sections, :emailing_sections_attributes

  has_attached_file :header_image,
                    styles: { large: '600x' },
                    convert_options: { large: '-interlace Plane' }

  has_many :emailing_sections

  accepts_nested_attributes_for :emailing_sections

  validates :title, presence: true
  validates :body, presence: true
  validates_attachment_content_type :header_image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
end
