class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  cached
  delegate :cache_key, to: :object

  attributes :id, :name, :slug, :comments_count, :logo_thumb_url, :logo_large_url,
              :data_url, :query_params, :structure_type, :highlighted_comment_title,
              :premium, :has_promotion, :is_open_for_trial, :cities, :cover_media, :subjects,
              :trial_courses_policy

  has_many :places,            serializer: PlaceSerializer
  has_many :medias,            serializer: ShortSerializer
  has_many :preloaded_medias,  serializer: MediaSerializer

  def medias
    object.medias.cover_first.videos_first.limit((object.premium? ? 20 : Media::FREE_PROFIL_LIMIT))
  end

  def preloaded_medias
    object.medias.cover_first.videos_first.limit((object.premium? ? 20 : Media::FREE_PROFIL_LIMIT))
  end

  def cover_media
    MediaSerializer.new(preloaded_medias.first) if preloaded_medias.first
  end

  def places
    if @options[:place_ids].present?
      place_ids = @options[:place_ids]
      object.places.where( Place.arel_table[:id].eq_any(place_ids) )
    elsif @options[:query] and @options[:query][:lat] and @options[:query][:lng]
      object.places_around @options[:query][:lat].to_f, @options[:query][:lng].to_f, (@options[:query][:radius] || 5)
    else
      object.places
    end
  end

  def highlighted_comment_title
    truncate(object.highlighted_comment.try(:title), length: 60) if object.comments_count > 0 and object.premium?
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
    structure_url(object, subdomain: subdomain, host: host, only_path: host.nil?)
  end

  def query_params
    @options[:query]
  end

  def premium
    object.premium?
  end

  def cities
    object.places(include: :city).map(&:city).map(&:name).uniq.join(', ')
  end

  def is_open_for_trial
    object.is_open_for_trial?
  end

  def subjects
    join_structure_course_subjects_text(object)
  end

  def trial_courses_policy
    I18n.t("structures.trial_courses_policy.#{object.trial_courses_policy}_nb")
  end
end
