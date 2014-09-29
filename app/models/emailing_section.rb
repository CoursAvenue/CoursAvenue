class EmailingSection < ActiveRecord::Base

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :title, :link, :link_name, :structures, :structure_ids

  belongs_to :emailing, polymorphic: true

  has_many :emailing_section_bridges
  has_many :structures, through: :emailing_section_bridges

  accepts_nested_attributes_for :structures

  validates :title, presence: true

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Get the EmailingSectionBridges associated with a structure
  #
  # @param The associated Structure
  #
  # @return an EmailingSectionBridge or nil
  def media_with_structure(structure)
    self.emailing_section_bridges.where(structure_id: structure.id).first
  end

  # Set the media by default if it isn't already set.
  #
  # If the Structure doesn't have any media, we store its id and add a flag showing
  # that we use the logo instead.
  #
  # @return nothing
  def set_media
    self.structures.each do |structure|
      bridge = media_with_structure(structure)

      if structure.medias.any?
        is_logo = false
        media = structure.medias.first.id
      else
        is_logo = true
        media = structure.id
      end

      if bridge.nil?
        self.emailing_section_bridges.create(structure_id: structure.id,
                                                 media_id: media,
                                                  is_logo: is_logo)
      elsif bridge.media_id.nil?
        bridge.media_id = media
        bridge.is_logo = is_logo
        bridge.save
      end
    end
  end

end
