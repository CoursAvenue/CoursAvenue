class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  attributes :id, :name, :slug, :comments_count, :logo_thumb_url, :logo_large_url, :data_url, :query_url, :query_params,
             :structure_type, :highlighted_comment_title, :premium, :promotion_title, :cities,
             :regular_courses_plannings_count, :training_courses_plannings_count

  has_many :places,            serializer: PlaceSerializer
  has_many :comments,          serializer: ShortSerializer
  has_many :medias,            serializer: ShortSerializer
  has_many :preloaded_medias,  serializer: MediaSerializer

  def medias
    (object.premium? ? object.medias.videos_first.limit(20) : object.medias.cover_first.limit(Media::FREE_PROFIL_LIMIT))
  end

  def preloaded_medias
    (object.premium? ? object.medias.videos_first.limit(20) : object.medias.cover_first.limit(Media::FREE_PROFIL_LIMIT))
  end

  def comments
    result = object.comments.accepted
    result = result.limit(5) unless options.key? :unlimited_comments

    return result
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
    truncate(object.highlighted_comment_title, length: 60) if object.comments_count > 0 and object.premium?
  end

  def structure_type
    I18n.t(object.structure_type) if object.structure_type.present? and object.structure_type != 'object.structure_type'
  end

  def funding_types
    object.funding_types.map{|funding| I18n.t(funding.name)}.join(', ')
  end

  def logo_thumb_url
    if object.is_sleeping?
      object.sleeping_logo.url(:thumb)
    else
      object.logo.url(:thumb)
    end
  end

  def logo_large_url
    if object.is_sleeping?
      object.sleeping_logo.url(:large)
    else
      object.logo.url(:large)
    end
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
    if @options[:jpo]
      jpo_structure_url(object, subdomain: subdomain, host: host, only_path: host.nil?)
    else
      structure_url(object, subdomain: subdomain, host: host, only_path: host.nil?)
    end
  end

  # this is for the href attributes on the filtered search page,
  # so that they can point at a structure url with the params
  def query_url
    data_url + "?" + (@options[:query_string] || '')
  end

  def query_params
    if @options[:jpo]
      (@options[:query] || {}).merge({
        course_types: ['open_course'],
        start_date:   '05/04/2014',
        end_date:     '06/04/2014'
      })
    else
      @options[:query]
    end
  end

  def tag_names
    if @options[:jpo]
      object.open_course_subjects
    else
      tags = []
      tags << object.parent_subjects_string.split(';').collect do |subject_string|
        subject_string.split(':')[0]
      end
      tags << object.subjects_string.split(';').collect do |subject_string|
        subject_string.split(':')[0]
      end
      if object.course_names.present?
        "#{tags.flatten.uniq.join(', ')}, #{object.course_names}"
      else
        tags.flatten.uniq.join(', ')
      end
    end
  end

  def premium
    object.premium?
  end

  def promotion_title
    if object.premium?
      if object.has_free_trial_course? and object.has_promotion?
        "Essai gratuit & promotions"
      elsif object.has_promotion?
        "Promotions"
      elsif object.has_free_trial_course?
        "Essai gratuit"
      end
    end
  end

  def cities
    object.places.map(&:city).map(&:name).uniq.join(', ')
  end

  def regular_courses_plannings_count
    PlanningSearch.search({ structure_id: object.id,
                            course_types: ['lesson', 'private'],
                            visible: true }.merge(@options[:query])).total
  end

  def training_courses_plannings_count
    PlanningSearch.search({ structure_id: object.id,
                            course_types: ['training'],
                            visible: true }.merge(@options[:query])).total
  end
end
