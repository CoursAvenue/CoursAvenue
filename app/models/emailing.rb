class Emailing < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  SECTION_METADATA = [
    { title: 'Nom'          , action: :metadata_name },
    { title: "Nombre d'avis", action: :metadata_comment_count },
    { title: 'À partir de'  , action: :metadata_prices },
    { title: 'Villes'       , action: :metadata_cities }
  ]

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :title, :body, :header_image, :section_metadata_one,
                  :section_metadata_two, :section_metadata_three,
                  :emailing_sections, :emailing_sections_attributes

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

  after_save :set_media

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Check if we should reject the section.
  # We only reject the section if the title is blank.
  #
  # @return a Boolean
  def reject_section(attributes)
    blank = attributes[:title].blank?

    if blank
      attributes.merge!({:_destroy => 1})
    end

    blank
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
    if action.present? and structure.present?
      self.send(action, structure)
    else
      nil
    end
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

  # The lowest price of a lesson by this structure."
  #
  # @return a String.
  def metadata_prices(structure)
    lowest_price = Structure.first.prices.min{ |a, b| a.amount <=> b.amount }.amount

    "À partir de #{lowest_price} €"
  end

  # The city of the structure.
  #
  # @return a String.
  def metadata_cities(structure)
    structure.city.name
  end

  # Set the media before saving if it isn't already set.
  #
  # @return nothing
  def set_media
    self.emailing_sections.each do |section|
      section.set_media
    end
  end

end
