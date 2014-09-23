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
end
