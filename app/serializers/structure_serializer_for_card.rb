class StructureSerializerForCard < ActiveModel::Serializer
  include StructuresHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :name, :slug, :about

  def about
    I18n.t("structures.structure_type_contact.#{(object.structure_type.present? ? object.structure_type : 'structures.other')}")
  end
end
