class ShortSerializer < ActiveModel::Serializer
    attributes :id
end

class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  attributes :id, :name, :slug, :comments_count, :rating, :street, :zip_code,
             :logo_present, :logo_thumb_url, :data_url,
             :courses_count, :has_courses, :plannings_count, :has_plannings, :more_than_five_comments, :has_comments,
             :min_price_amount, :min_price_libelle, :max_price_amount, :max_price_libelle, :has_price_range,
             :has_free_trial_course, :medias_count, :teaches_at_home, :teaches_at_home_radius, :videos_count, :images_count,
             :audience, :funding_types, :gives_group_courses, :gives_individual_courses, :structure_type,
             :has_promotion, :course_names, :last_comment_title

  has_many :places
  has_many :comments, serializer: ShortSerializer
  has_many :courses,  serializer: ShortSerializer
  has_many :medias,   serializer: ShortSerializer
  has_many :preloaded_medias,  serializer: MediaSerializer

  # Following functions has to return the same objects than the associated controllers
  def courses
    object.courses.active
  end

  def medias
    object.medias.videos_first.limit(20)
  end

  def comments
    object.comments.accepted.limit(5)
  end

  # TODO Use MediaSerializer
  def preloaded_medias
    object.medias.videos_first.limit(6)
  end

  def last_comment_title
    truncate(object.comments.accepted.first.title, length: 60) if object.comments_count > 0
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

  def has_price_range
    object.min_price and object.max_price
  end

  def min_price_amount
    object.min_price.amount.to_i if object.min_price
  end

  def min_price_libelle
    object.min_price.localized_libelle if object.min_price
  end

  def max_price_amount
    object.max_price.amount.to_i if object.max_price
  end

  def max_price_libelle
    object.max_price.localized_libelle if object.max_price
  end

  def more_than_five_comments
    object.comments_count > 5
  end

  def has_comments
    object.comments.accepted.count > 0
  end

  def plannings_count
    object.plannings_count
  end

  def has_plannings
    object.plannings_count > 0 if object.plannings_count
  end

  def courses_count
    object.courses.count
  end

  def has_courses
    object.courses.count > 0
  end

  def logo_present
    object.logo.present?
  end

  def logo_thumb_url
    if Rails.env.development?
      'http://placehold.it/200'
    elsif object.logo.present?
      object.logo.url(:thumb)
    end
  end

  def data_url
    structure_path(object)
  end

  def course_names
    if object.course_names.present?
      object.course_names
    else
      join_child_subjects_text(object)
    end
  end
end
