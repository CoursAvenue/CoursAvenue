class EmailingSectionBridgeSerializer < ActiveModel::Serializer
  attributes :media_id, :media_url, :images

  def images
    object.structure.medias.images.map do |media|
      { id: media.id, url: media.image.url }
    end
  end
end
