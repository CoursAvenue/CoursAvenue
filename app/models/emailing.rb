class Emailing < ActiveRecord::Base

  ######################################################################
  # Constant                                                           #
  ######################################################################

  SECTION_METADATA = [
    { title: 'Nom'          , action: :metadata_name },
    { title: "Nombre d'avis", action: :metadata_comment_count }, # TODO: => comments.count
    { title: 'À partir de',   action: :metadata_prices },        # TODO: => prices. ???
    { title: 'Villes',        action: :metadata_cities }
  ]

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :title, :body, :header_image, :section_metadata_one, :section_metadata_two, :section_metadata_three, :emailing_sections, :emailing_sections_attributes

  has_attached_file :header_image,
                    styles: { large: '600x' },
                    convert_options: { large: '-interlace Plane' }

  has_many :emailing_sections

  accepts_nested_attributes_for :emailing_sections,
                                 reject_if: :reject_section,
                                 allow_destroy: true

  validates :title, presence: true
  validates :body, presence: true
  validates_attachment_content_type :header_image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Check if we should reject the section.
  # We only reject the section if the title is blank.
  #
  # @return a Boolean
  def reject_section(attributes)
    attributes[:title].blank?
  end

  # Puts the three section_metadata in a Array.
  #
  # @return Array of String
  def section_metadata
    [section_metadata_one, section_metadata_two, section_metadata_three]
  end

  # Call the specified method on the structure.
  #
  # @return a String
  def call_action(action, structure)
    self.send(action, structure)
  end

  private

  # The name of the structure
  #
  # @return a String.
  def metadata_name(structure)
    structure.name
  end

  # The number of comments of the structure.
  #
  # @return a String.
  def metadata_comment_count(structure)
    "#{structure.comments.count} avis"
  end

  # TODO: TBD
  #
  # @return a String.
  def metadata_prices(structure)
  end

  # The city of the structure.
  #
  # @return a String.
  def metadata_cities(structure)
    structure.city.name
  end

end
