class ShortSerializer < ActiveModel::Serializer
    attributes :id
end

class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper

  attributes :id, :name, :slug, :comments_count, :rating, :street, :zip_code,
             :logo_present, :logo_thumb_url, :parent_subjects_text, :parent_subjects, :child_subjects, :data_url,
             :subjects_count, :too_many_subjects, :subjects, :courses_count
  has_many :places
  has_many :comments, serializer: ShortSerializer
  has_many :courses, serializer: ShortSerializer

  def comments
    object.comments.limit(5).order(created_at: :desc)
  end

  def courses_count
    self.courses.count
  end

  def logo_present
    object.logo.present?
  end

  def logo_thumb_url
    # object.logo.url(:thumb)
    "http://placehold.it/100"
  end

  def parent_subjects_text
    join_parent_subjects_text(object)
  end

  def data_url
    structure_path(object)
  end

  def subjects_count
    object.subjects.count
  end

  def too_many_subjects
    subjects.count > 5
  end

  def parent_subjects
    object.parent_subjects_array.map do |subject_hash|
      { name: subject_hash[:name], path: subject_structures_path(subject_hash[:slug]) }
    end
  end

  def child_subjects
    object.subjects_array.map do |subject_hash|
      { name: subject_hash[:name], path: subject_structures_path(subject_hash[:slug]) }
    end
  end
end
