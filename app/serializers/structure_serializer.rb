class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  attributes :id, :name, :slug, :comments_count, :rating, :street, :zip_code,
             :logo_thumb_url, :data_url, :query_url, :query_params,
             :courses_count, :has_courses, :plannings_count, :has_plannings, :more_than_five_comments, :has_comments,
             :min_price_amount, :min_price_libelle, :max_price_amount, :max_price_libelle,
             :has_free_trial_course, :medias_count, :teaches_at_home, :teaches_at_home_radius, :videos_count, :images_count,
             :audience, :gives_group_courses, :gives_individual_courses, :structure_type,
             :has_promotion, :tag_names, :highlighted_comment_title, :open_courses_open_places, :open_course_names, :open_course_plannings_nb,
             :given_course_types, :premium, :promotion_title, :cities, :regular_courses_plannings_count, :training_courses_plannings_count

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

  def audience
    object.audiences.sort_by(&:order).map{|audience| I18n.t(audience.name)}.join(', ')
  end

  def medias_count
    if object.premium?
      [object.medias.count, 20].min
    else
      object.medias.limit(3).count
    end
  end

  def videos_count
    (object.medias.videos.count == 0 ? nil : object.medias.videos.count)
  end

  def images_count
    (object.medias.images.count == 0 ? nil : object.medias.images.count)
  end

  def has_free_trial_course
    object.has_free_trial_course
  end

  def min_price_amount
    object.min_price_amount.to_i
  end

  def max_price_amount
    object.max_price_amount.to_i
  end

  def more_than_five_comments
    object.comments_count > 5
  end

  def has_comments
    object.comments.accepted.count > 0
  end

  def has_plannings
    object.plannings_count.to_i > 0 if object.plannings_count
  end

  def courses_count
    object.courses.count
  end

  def has_courses
    object.courses.count > 0
  end

  def logo_thumb_url
    object.logo.url(:thumb)
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

  def given_course_types
    types = []
    if object.teaches_at_home and object.places.homes.any?
      if object.places.homes.first.radius.present?
        types << "cours à domicile (#{object.places.homes.first.radius})"
      else
        types << "cours à domicile"
      end
    end
    if object.gives_group_courses
      types << 'cours collectifs'
    end
    if object.gives_individual_courses
      types << 'cours individuels'
    end
    types.join(', ')
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
    object.places.map(&:city).uniq.map(&:name).join(', ')
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
