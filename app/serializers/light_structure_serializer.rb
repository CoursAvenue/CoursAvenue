class ShortSerializer < ActiveModel::Serializer
  attributes :id
end

class LightStructureSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  attributes :id, :name, :slug, :comments_count, :rating, :street, :zip_code,
             :logo_present, :logo_thumb_url, :data_url,
             :courses_count, :has_courses, :plannings_count, :has_plannings, :more_than_five_comments, :has_comments,
             :min_price_amount, :min_price_libelle, :max_price_amount, :max_price_libelle, :has_price_range,
             :gives_group_courses, :gives_individual_courses,
             :has_promotion, :course_names, :last_comment_title

  has_many :places
  has_many :comments, serializer: ShortSerializer

  def comments
    object.comments.accepted.limit(5)
  end

  def has_price_range
    object.min_price and object.max_price
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
    structure_url(object, subdomain: 'www')
  end

  def course_names
    if object.course_names.present?
      object.course_names
    else
      join_child_subjects_text(object)
    end
  end
end
