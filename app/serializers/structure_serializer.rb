class ShortSerializer < ActiveModel::Serializer
    attributes :id
end

class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper

  attributes :id, :name, :slug, :comments_count, :rating, :street, :zip_code,
             :logo_present, :logo_thumb_url, :child_subjects, :data_url,
             :subjects_count, :subjects, :courses_count, :more_than_five_comments,
             :min_price_amount, :min_price_libelle, :max_price_amount, :max_price_libelle, :has_price_range,
             :has_free_trial_course, :medias_count, :teaches_at_home

  has_many :places
  has_many :comments, serializer: ShortSerializer
  has_many :courses, serializer: ShortSerializer

  def medias_count
    (object.medias.count == 0 ? nil : object.medias.count)
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

  def comments
    object.comments.title_ordered_first.limit(5)
  end

  def courses_count
    self.courses.count
  end

  def logo_present
    object.logo.present?
  end

  def logo_thumb_url
    if Rails.env.development?
      'http://placehold.it/200'
    else
      object.logo.url(:thumb)
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
