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
             :audience, :funding_types, :gives_group_courses, :gives_individual_courses, :has_medias, :structure_type,
             :has_promotion, :parent_subjects_text, :last_comment_title

  has_many :places
  has_many :comments, serializer: ShortSerializer
  has_many :courses,  serializer: ShortSerializer
  has_many :medias,   serializer: MediaSerializer
  # has_many :medias,   serializer: ShortSerializer

  # Following functions has to return the same objects than the associated controllers
  def courses
    object.courses.active
  end

  def medias
    object.medias.videos_first.limit(9)
  end

  def comments
    object.comments.accepted.limit(5)
  end

  def last_comment_title
    truncate(object.comments.accepted.first.title, length: 40) if object.comments_count > 0
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

  def has_medias
    (object.medias.images.count + object.medias.videos.count) > 0
  end

  def medias_count
    object.medias.images.count + object.medias.videos.count
  end


  def videos_count
    (object.medias.videos.count == 0 ? nil : object.medias.videos.count)
  end

  def images_count
    (object.medias.images.count == 0 ? nil : object.medias.images.count)
  end

  def has_free_trial_course
    object.prices.where{(type == 'Price::Trial') & ((amount == nil) | (amount == 0))}.any?
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
    object.comments.count > 5
  end

  def has_comments
    object.comments.count > 0
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
    object.logo.present? or object.image.present?
  end

  def logo_thumb_url
    if Rails.env.development?
      'http://placehold.it/200'
    else
      if object.logo.present?
        object.logo.url(:thumb)
      elsif object.image.present?
        object.image.url(:thumb)
      end
    end
  end

  def data_url
    structure_path(object)
  end

  def parent_subjects_text
    join_parent_subjects_text(object)
  end
end
