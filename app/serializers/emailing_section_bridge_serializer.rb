class EmailingSectionBridgeSerializer < ActiveModel::Serializer
  attributes :id, :media_id, :media_url, :images

  # Simplify the images to return.
  #
  # @return An Array of Hashes containing some images attributes.
  def images
    object.structure.medias.map do |media|
      if media.type == 'Media::Video'
        { id: media.id, url: media.thumbnail_url }
      else
        { id: media.id, url: media.image.url }
      end
    end
  end
end
