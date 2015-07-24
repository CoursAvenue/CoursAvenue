class EmailingSection < ActiveRecord::Base

  ######################################################################
  # Macros                                                             #
  ######################################################################

  attr_accessible :title, :link, :link_name, :structures, :structure_ids,
                  :indexable_cards, :indexable_card_ids

  belongs_to :emailing

  has_many :emailing_section_bridges

  has_many :structures,      through: :emailing_section_bridges
  has_many :indexable_cards, through: :emailing_section_bridges

  accepts_nested_attributes_for :structures
  accepts_nested_attributes_for :indexable_cards

  ######################################################################
  # Methods                                                            #
  ######################################################################

  # Get the EmailingSectionBridges associated with a structure
  #
  # @param The associated Structure
  #
  # @return an EmailingSectionBridge or nil
  def bridge_with_structure(structure)
    self.emailing_section_bridges.where(structure_id: structure.id).first
  end

  def bridge_with_card(card)
    self.emailing_section_bridges.where(indexable_card_id: card.id).first
  end

  # Set the media, subject and reviews by default.
  #
  # @return nothing
  def set_defaults
    self.indexable_cards.each do |card|
      bridge = bridge_with_card(card) || self.emailing_section_bridges.create(indexable_card_id: card.id)
      structure = card.structure

      set_media(bridge, structure)   if bridge.media_id.nil?
      set_review(bridge, structure)  if bridge.review_id.nil?
      set_subject(bridge, structure) if bridge.subject_id.nil?
      set_city(bridge, structure)    if bridge.city_text.nil?
    end

    _structures = self.structures - self.indexable_cards.flat_map(&:structure)

    _structures.each do |structure|
      bridge = bridge_with_structure(structure) || self.emailing_section_bridges.create()
      set_media(bridge, structure)   if bridge.media_id.nil?
      set_review(bridge, structure)  if bridge.review_id.nil?
      set_subject(bridge, structure) if bridge.subject_id.nil?
      set_city(bridge, structure)    if bridge.city_text.nil?
    end
  end

  private

  # Set the media by default if it isn't already set.
  #
  # If the Structure doesn't have any media, we store its id and add a flag showing
  # that we use the logo instead.
  #
  # @return nothing
  def set_media(bridge, structure)
    if structure.medias.any?
      is_logo = false
      media = structure.medias.first.id
    else
      is_logo = true
      media = structure.id
    end

    bridge.media_id = media
    bridge.is_logo = is_logo
    bridge.save
  end

  # Set the subject by default if it isn't already set.
  #
  # @param bridge    — The bridge to set the default subject.
  # @param structure — The structure from which the default values are set.
  #
  # @return nothing.
  def set_subject(bridge, structure)
    subject = structure.subjects.first

    if subject.present?
      bridge.subject_id = subject.id
      bridge.subject_name = subject.name
      bridge.save
    end
  end

  # Set the review by default if it isn't already set.
  #
  # @return nothing
  def set_review(bridge, structure)
    review = structure.comments.first

    if review.present?
      bridge.review_id = review.id
      bridge.review_text = review.title
      bridge.review_custom = false
      bridge.save
    end
  end

  # Set the city name by default if it isn't already set.
  #
  # @return nothing.
  def set_city(bridge, structure)
    bridge.city_text = self.emailing.call_action(:metadata_cities, structure)
    bridge.save
  end
end
