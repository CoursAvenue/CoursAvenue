class TeacherSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image, :structure_id

  def description
    object.description.force_encoding(Encoding::ISO_8859_1) if object.description
  end

  def image
    object.image.url(:normal)
  end
end
