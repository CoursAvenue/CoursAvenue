class SubjectListSerializer < ActiveModel::Serializer
  attributes :name, :slug, :root_slug

  cached
  delegate :cache_key, to: :object

  def root_slug
    object.root.slug
  end
end
