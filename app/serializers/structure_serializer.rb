class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  cached
  def cache_key
    'StructureSerializer/' + object.cache_key
  end

  attributes :id, :name, :slug, :comments_count, :logo_thumb_url, :logo_thumb_url_2x, :logo_large_url,
              :data_url, :query_params, :structure_type, :highlighted_comment_title,
              :has_promotion, :is_open_for_trial, :cover_media, :subjects,
              :cities_text, :min_price_amount, :about

  has_many :places,            serializer: PlaceSerializer
  has_many :preloaded_medias,  serializer: MediaSerializer

  def preloaded_medias
    object.medias.cover_first.videos_first.limit(10)
  end

  def cover_media
    MediaSerializer.new(preloaded_medias.first) if preloaded_medias.any?
  end

  def places
    if @options and @options[:place_ids].present?
      place_ids = @options[:place_ids]
      object.places.where( Place.arel_table[:id].eq_any(place_ids) )
    elsif @options and @options[:query] and @options[:query][:lat] and @options[:query][:lng]
      object.places_around @options[:query][:lat].to_f, @options[:query][:lng].to_f, (@options[:query][:radius] || 5)
    else
      object.places
    end
  end

  def highlighted_comment_title
    (object.highlighted_comment || object.comments.first).try(:title) if object.comments_count > 0
  end

  def structure_type
    I18n.t(object.structure_type) if object.structure_type.present? and object.structure_type != 'object.structure_type'
  end

  def funding_types
    object.funding_types.map{|funding| I18n.t(funding.name)}.join(', ')
  end

  def logo_thumb_url
    object.logo.url(:small_thumb_100)
  end

  def logo_thumb_url_2x
    object.logo.url(:small_thumb)
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
      host      = 'coursaven.eu'
    end
    structure_url(object, subdomain: subdomain, host: host, only_path: host.nil?)
  end

  def query_params
    @options[:query]
  end

  def subjects
    join_structure_course_subjects_text(object)
  end

  def is_open_for_trial
    object.is_open_for_trial?
  end

  def min_price_amount
    object.min_price_amount.to_i
  end

  def about
    I18n.t("structures.structure_type_contact.#{(object.structure_type.present? ? object.structure_type : 'structures.other')}")
  end
end
