class AdminSerializer < ActiveModel::Serializer
  attributes :id, :structure_id, :structure_slug

  cached
  delegate :cache_key, to: :object

  def structure_slug
    object.structure.try(:slug)
  end
end
