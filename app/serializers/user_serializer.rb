class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :first_name, :last_name, :avatar_url, :slug, :favorite_structure_ids

  def favorite_structure_ids
    object.followings.map(&:structure_id)
  end
end
