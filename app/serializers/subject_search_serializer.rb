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
    object.parent.slug unless object.depth == 0
  end

  def root
    object.root.slug unless object.depth == 0
  end

end
