class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :grand_children

  def grand_children
    result = object.descendants.at_depth(2).map do |grand_child|
      {
        name: grand_child.name,
        slug: grand_child.slug
      }
    end
  end

end
