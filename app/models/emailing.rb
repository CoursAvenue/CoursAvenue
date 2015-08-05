class Emailing < ActiveRecord::Base

  ######################################################################
  # Constants                                                          #
  ######################################################################

  SECTION_METADATA = [
    { title: 'Nom'           , action: :metadata_name },
    # { title: "Nombre d'avis" , action: :metadata_comment_count },
    # { title: "Titre avis"    , action: :metadata_comment_title },
    { title: 'À partir de'   , action: :metadata_prices },
    { title: 'Villes'        , action: :metadata_cities },
    { title: 'Discipline'    , action: :metadata_subject }
  ]

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :title, :body, :header_image, :header_url, :header_image_alt, :section_metadata_one,
                  :section_metadata_two, :section_metadata_three,
                  :emailing_sections, :emailing_sections_attributes,
                  :call_to_action_text, :call_to_action_url

  has_attached_file :header_image,
                    styles: { large: '600x' },
                    convert_options: { large: '-interlace Plane' },
                    processors: [:thumbnail, :paperclip_optimizer]

  has_many :emailing_sections

  accepts_nested_attributes_for :emailing_sections,
                                 reject_if: :reject_section,
                                 allow_destroy: true

  validates :title, presence: true
  validates :body, presence: true
  validates_attachment_content_type :header_image, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

  after_save :set_defaults

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Check if we should reject the section.
  # We only reject the section if the title is blank.
  #
  # @return a Boolean
  def reject_section(attributes)
    exists = attributes[:id].present?
    blank  = (attributes[:title].blank? and attributes[:link].blank? and
              (attributes[:structure_ids].blank? and attributes[:indexable_card_ids].blank?))

    if blank and exists
      attributes.merge!({:_destroy => 1})
    end

    (blank and !exists)
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

  # The number of comments of the structure.
  #
  # @return a String.
  def metadata_comment_title(structure)
    "#{(structure.highlighted_comment || structure.comments.last).title} (#{structure.comments_count} avis)"
  end

  # The lowest price of a lesson by this structure."
  #
  # @return a String.
  def metadata_prices(structure)
    lowest_price = structure.prices.min{ |a, b| a.amount <=> b.amount }.amount

    "À partir de #{lowest_price} €"
  end

  # Where the courses of the structure are taking place.
  #
  # @return a String.
  def metadata_cities(structure)
    place = []
    courses = structure.courses

    place << 'A domicile' if courses.where(type: 'Course::Private').any?
    if (public_courses = courses.where.not(type: 'Course::Private')).any?
      place += public_courses.flat_map(&:places).flat_map(&:city).uniq.map(&:name).sort
    end

    place.first(3).to_sentence
  end

  # The first subject of the structure.
  #
  # @return a String.
  def metadata_subject(structure)
    structure.subjects.first.name
  end

  # Set the media before saving if it isn't already set.
  #
  # @return nothing
  def set_defaults
    self.emailing_sections.each do |section|
      section.set_defaults
    end
  end
end
