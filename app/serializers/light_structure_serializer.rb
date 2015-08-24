class LightStructureSerializer < ActiveModel::Serializer
  include StructuresHelper
  include ActionView::Helpers::TextHelper

  cached
  def cache_key
    'LightStructureSerializer/' + object.cache_key
  end

  attributes :id, :name, :slug, :comments_count, :rating, :street, :zip_code,
             :logo_thumb_url, :data_url,
             :plannings_count, :more_than_five_comments, :has_comments,
             :min_price_amount, :max_price_libelle,
             :gives_group_courses, :gives_individual_courses,
             :has_promotion, :course_names, :highlighted_comment_title

  has_many :places
  has_many :comments, serializer: ShortSerializer

  def comments
    object.comments.accepted.limit(5)
  end

  def more_than_five_comments
    object.comments_count > 5
  end

  def has_comments
    object.comments.accepted.count > 0
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
