module StructuresHelper

  def cache_key_for_structures
    count          = Structure.count
    max_updated_at = Structure.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "structures/all-#{count}-#{max_updated_at}"
  end

  def join_child_subjects(structure, with_h3 = false)
    structure.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      content_tag(:li) do
        content_tag((with_h3 ? :h3: :span), class: 'flush--bottom inherit-font-size') do
          link_to subject_name, structures_path(name: subject_name), class: 'lbl milli inline subject-link'
        end
      end
    end.join(' ').html_safe
  end

  def join_child_subjects_text(structure)
    structure.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      subject_name
    end.join(', ').html_safe
  end

  def join_parent_subjects(structure, with_h3 = false)
    structure.parent_subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      content_tag(:li) do
        content_tag((with_h3 ? :h3: :span), class: 'flush--bottom inherit-font-size') do
          link_to subject_name, structures_path(name: subject_name), class: 'lbl milli inline subject-link'
        end
      end
    end.join(' ').html_safe
  end

  def join_parent_subjects_text(structure)
    structure.parent_subjects_string.split(';').collect do |subject_string|
      subject_string.split(':')[0]
    end.join(', ').html_safe
  end

end
