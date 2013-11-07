class ShortSerializer < ActiveModel::Serializer
    attributes :id
end

class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper

  attributes :id, :name, :slug, :comments_count, :rating, :street, :zip_code,
             :logo_present, :logo_thumb_url, :child_subjects, :data_url,
             :subjects_count, :subjects, :courses_count, :has_courses, :plannings_count, :more_than_five_comments, :has_comments,
             :min_price_amount, :min_price_libelle, :max_price_amount, :max_price_libelle, :has_price_range,
             :has_free_trial_course, :medias_count, :teaches_at_home, :teaches_at_home_radius, :videos_count, :images_count,
             :audience, :funding_types, :gives_group_courses, :gives_individual_courses

  has_many :places
  has_many :comments, each_serializer: ShortSerializer
  has_many :courses, each_serializer: ShortSerializer
  has_many :medias, each_serializer: ShortSerializer

  def funding_types
    object.funding_types.map{|funding| I18n.t(funding.name)}.join(', ')
  end

  def audience
    object.audiences.sort_by(&:order).map{|audience| I18n.t(audience.name)}.join(', ')
  end

  def medias_count
    (object.medias.count == 0 ? nil : object.medias.count)
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

  def comments
    object.comments.limit(5)
  end

  def plannings_count
    object.plannings.count
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

  def subjects_count
    object.subjects.count
  end

  def child_subjects
    if object.subjects_array.length > 4
      at_depth_1_subjects = object.subjects.at_depth(2).collect(&:parent)
      at_depth_1_subjects.uniq.map do |subject_hash|
        { name: subject_hash[:name], path: subject_structures_path(subject_hash[:slug]) }
      end
    else
      object.subjects_array.map do |subject_hash|
        { name: subject_hash[:name], path: subject_structures_path(subject_hash[:slug]) }
      end
    end
  end
end
