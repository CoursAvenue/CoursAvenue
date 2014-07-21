class StructureShowSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  attributes :id, :name, :slug, :rating, :street, :zip_code, :description,
             :logo_thumb_url, :data_url, :query_url, :query_params, :courses, :courses_count,
             :has_courses, :plannings_count, :has_plannings,
             :min_price_amount, :min_price_libelle, :max_price_amount, :max_price_libelle, :has_price_range,
             :has_free_trial_course, :medias_count, :teaches_at_home, :videos_count, :images_count,
             :audience, :funding_types, :gives_group_courses, :gives_individual_courses, :structure_type,
             :has_promotion, :tag_names, :given_course_types, :given_funding_type, :places_count, :comments

  has_many :comments, serializer: CommentSerializer
  has_many :places
  has_many :teachers, serializer: ShortSerializer

  def comments
    object.comments.limit(5)
  end

  def courses
    if @options[:planning_groups]
      object.courses.active.where(id: @options[:planning_groups].keys).map do |course|
        CourseSerializer.new(course, plannings: @options[:planning_groups][course.id])
      end
    end
  end

  def medias
    object.medias.videos_first.limit(20)
  end

  def places_count
    object.places.count
  end

  def places
    if @options[:place_ids].present?
      place_ids = @options[:place_ids]
      object.places.where( Place.arel_table[:id].eq_any(place_ids) )
    else
      object.places
    end
  end

  # TODO Use MediaSerializer
  def preloaded_medias
    object.medias.videos_first.limit(6)
  end

  def structure_type
    I18n.t(object.structure_type) if object.structure_type.present?
  end

  def funding_types
    object.funding_types.map{|funding| I18n.t(funding.name)}.join(', ')
  end

  def audience
    object.audiences.sort_by(&:order).map{|audience| I18n.t(audience.name)}.join(', ')
  end

  def medias_count
    [object.medias.count, 20].min
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

  def has_price_range
    object.min_price_amount.present? and object.max_price_amount.present?
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
    data_url + "?" + @options[:query_string]
  end

  def query_params
    @options[:query]
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
    types.join(', ').capitalize
  end

  def given_funding_type
    object.funding_types.map{ |funding_type| I18n.t(funding_type.name)}.join(', ')
  end
end
