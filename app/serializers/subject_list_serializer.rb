class SubjectListSerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  attributes :name, :slug, :root_slug

  def root_slug
    object.root.slug
  end
end
