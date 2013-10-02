class StructureSerializer < ActiveModel::Serializer
  attributes :id, :name, :subjects, :comments_count, :rating, :street, :zip_code, :slug

end
