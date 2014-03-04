class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :children, :grand_children

  def children
    object.children
  end

  def grand_children
    result = object.children.map do |child|
      child.children.map(&:name)
    end

    result.flatten
  end

end
