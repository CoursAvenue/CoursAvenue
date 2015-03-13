class SubjectSearchSerializer < ActiveModel::Serializer
  attributes :type, :name, :slug, :depth, :root, :parent

  cached
  delegate :cache_key, to: :object

  def type
    'subject'
  end

  def type_name
    'Disciplines'
  end

  def parent
    object.parent.slug if object.parent
  end

  def root
    object.root.slug
  end

end
