class StructureSerializer < ActiveModel::Serializer
  include StructuresHelper

  attributes :id, :name, :slug, :comments_count, :rating, :street, :zip_code
  attributes :logo_present, :logo_url, :parent_subjects_text, :parent_subjects, :child_subjects, :data_url
  attributes :subjects_count, :too_many_subjects, :subjects

  def logo_present
    object.logo.present?
  end

  def logo_url
    object.logo.url(:thumb)
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
    object.parent_subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')

      { name: subject_name, path: subject_structures_path(subject_slug) }
    end
  end

  def child_subjects
    object.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')

      { name: subject_name, path: subject_structures_path(subject_slug) }
    end
  end
end
