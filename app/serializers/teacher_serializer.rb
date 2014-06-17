class TeacherSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image, :structure_id

  def image
    object.image.url(:normal)
  end
end
