class StructureTypeaheadSerializer < ActiveModel::Serializer

  attributes :type, :name, :slug, :url, :logo_url

  def type
    'structure'
  end

  def url
    structure_path(object, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)
  end

  def logo_url
    object.logo.url(:small_thumb)
  end
end
