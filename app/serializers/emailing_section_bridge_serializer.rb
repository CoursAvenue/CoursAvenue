class EmailingSectionBridgeSerializer < ActiveModel::Serializer
  attributes :id, :media_id, :media_url, :images, :structure,
    :subjects, :subject_id, :subject_name,
    :reviews, :review_id, :review_text, :review_custom,
    :city_text, :indexable_card

  # Get the relevant information about a Structure instead of sending the
  # full object.
  #
  # @return a Hash.
  def structure
    structure = object.structure || object.indexable_card.structure
    section = object.emailing_section.emailing
    actions = section.section_metadata
    {
      id: structure.id,
      metadata_1: section.call_action(actions[0], structure),
      metadata_2: section.call_action(actions[1], structure),
      metadata_3: section.call_action(actions[2], structure)
    }
  end

  def indexable_card
    return nil if object.indexable_card.nil?

    {
      id: object.indexable_card.id,
    }
  end

  # Simplify the images to return.
  #
  # @return An Array of Hashes containing some images attributes.
  def images
    _structure = object.structure || object.indexable_card.structure

    _structure.medias.map do |media|
      if media.type == 'Media::Video'
        { id: media.id, url: media.thumbnail_url }
      else
        { id: media.id, url: media.image.url(:thumbnail_email_cropped) }
      end
    end
  end

  # Simplify the subjects to return.
  #
  # @return an Array of Hashes containing some subjects attributes.
  def subjects
    _structure = object.structure || object.indexable_card.structure

    _structure.subjects.map do |subject|
      { id: subject.id, name: subject.name }
    end
  end

  # Simplify the reviews to return.
  #
  # @return an Array of reviews attributes.
  def reviews
    _structure = object.structure || object.indexable_card.structure

    _structure.comments.map do |review|
      { id: review.id, text: review.title, custom: false }
    end.select { |comment| comment[:text].present? }
  end
end
