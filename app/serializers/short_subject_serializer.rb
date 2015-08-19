class ShortSubjectSerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  attributes :id, :slug, :name, :root_slug

  def root_slug
    object.root.slug
  end

end
