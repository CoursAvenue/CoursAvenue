class TeacherSerializer < ActiveModel::Serializer
  include ActionView::Helpers::TextHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :name, :description, :description_short, :image, :structure_id

  def image
    object.image.url(:normal)
  end

  def description_short
    truncate(object.description, :length => 30, :separator => ' ') if object.description
  end
end
