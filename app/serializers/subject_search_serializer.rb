class SubjectSearchSerializer < ActiveModel::Serializer
  attributes :type, :name, :slug, :depth, :root, :parent

  def type
    'subject'
  end

  def parent
    object.parent.slug unless object.depth == 0
  end

  def root
    object.root.slug unless object.depth == 0
  end

end
