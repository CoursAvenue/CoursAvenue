class StructureDiscoveryPassSearchSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  attributes :id, :name, :slug, :comments_count, :logo_thumb_url, :logo_large_url, :data_url, :query_params,
             :structure_type, :highlighted_comment_title, :subjects, :cover_media

  has_many :places,            serializer: PlaceSerializer
  has_many :comments,          serializer: ShortSerializer
  has_many :medias,            serializer: ShortSerializer
  has_many :preloaded_medias,  serializer: MediaSerializer

  def medias
    object.medias.cover_first.videos_first.limit(20)
  end

  def preloaded_medias
    object.medias.cover_first.videos_first.limit(20)
  end

  def cover_media
    MediaSerializer.new preloaded_medias.first
  end

  def comments
    result = object.comments.accepted
    result = result.limit(5) unless options.key? :unlimited_comments

    return result
  end

  def places
    object.discovery_pass_places
  end

  def highlighted_comment_title
    truncate((object.highlighted_comment_title || object.comments.last.title), length: 60) if object.comments_count > 0
  end

  def structure_type
    I18n.t(object.structure_type) if object.structure_type.present? and object.structure_type != 'object.structure_type'
  end

  def funding_types
    object.funding_types.map{|funding| I18n.t(funding.name)}.join(', ')
  end

  def logo_thumb_url
    object.logo.url(:thumb)
  end

  def logo_large_url
    object.logo.url(:large)
  end

  def data_url
    subdomain = 'www'
    if Rails.env.production?
      host = 'coursavenue.com'
    elsif Rails.env.development?
      host = 'coursavenue.dev'
    elsif Rails.env.staging?
      host      = 'staging.coursavenue.com'
      subdomain = 'staging'
    end
    discovery_pass_structure_url(object, subdomain: subdomain, host: host, only_path: host.nil?)
  end

  def query_params
    @options[:query]
  end

  def subjects
    object.courses.available_in_discovery_pass.map(&:subjects).flatten.uniq.map(&:name).join(', ')
  end

end
