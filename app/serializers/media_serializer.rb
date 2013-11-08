class MediaSerializer < ActiveModel::Serializer

  attributes :id, :url, :url_html, :caption, :format

end
