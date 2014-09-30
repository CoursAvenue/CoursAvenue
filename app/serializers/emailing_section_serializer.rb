class EmailingSectionSerializer < ActiveModel::Serializer
  attributes :title, :link, :link_name, :emailing_section_bridges

  has_many :emailing_section_bridges, serializer: EmailingSectionBridgeSerializer
end
