class AdminSerializer < ActiveModel::Serializer
  attributes :id, :structure_id, :structure_slug

  cached
  def cache_key
    'AdminSerializer/' + object.cache_key + '/v1'
  end

  def structure_id
    object.structure.try(:id)
  end

  def structure_slug
    object.structure.try(:slug)
  end
end
