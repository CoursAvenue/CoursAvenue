class MediaSerializer < ActiveModel::Serializer

  cached
  delegate :cache_key, to: :object

  attributes :id, :url, :url_html, :caption, :format, :is_video, :thumbnail_url, :mediable_id

  def is_video
    object.video?
  end

end
