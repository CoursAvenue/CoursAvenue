class TeacherSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper
  attributes :id, :name, :description, :description_short, :image, :structure_id

  def image
    object.image.url(:normal)
  end

  def description_short
    truncate(object.description, :length => 100, :separator => ' ') if object.description
  end
end
