class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :children, :grand_children

  def children
    object.children
  end

  def grand_children
    result = object.children.map do |child|

      child.children.map do |grand_child|
        {
          name: grand_child.name,
          slug: grand_child.slug
        }
      end
    end

    result.flatten
  end

end
