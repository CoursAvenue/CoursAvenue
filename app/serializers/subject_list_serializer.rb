class SubjectListSerializer < ActiveModel::Serializer

  cached
  def cache_key
    'SubjectListSerializer/' + object.cache_key
  end

  attributes :name, :slug, :root_slug

  def root_slug
    object.root.slug
  end
end
