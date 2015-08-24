class SubjectSearchSerializer < ActiveModel::Serializer
  attributes :type, :name, :slug, :depth, :root, :parent

  cached
  def cache_key
    'SubjectSearchSerializer/' + object.cache_key
  end

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
