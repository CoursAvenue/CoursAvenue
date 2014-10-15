class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :children

  cached
  delegate :cache_key, to: :object

  def children
    object.children.order('name ASC').map do |first_child|
      first_child_json = {
        name: first_child.name,
        slug: first_child.slug
      }
      first_child_json[:children] = []
      first_child.children.order('name ASC').each do |child|
        first_child_json[:children] << { name: child.name, slug: child.slug } # , root-name: object.slug, parent-name: first_child.slug
      end
      first_child_json
    end
  end

end
