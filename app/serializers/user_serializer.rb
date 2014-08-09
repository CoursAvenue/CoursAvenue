class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :first_name, :last_name, :avatar_url, :slug

end
