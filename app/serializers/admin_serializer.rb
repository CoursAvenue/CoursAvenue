class AdminSerializer < ActiveModel::Serializer
  attributes :id, :structure_id, :structure_slug

  cached
  def cache_key
    'AdminSerializer/' + object.cache_key
  end

  def structure_slug
    object.structure.try(:slug)
  end
end
