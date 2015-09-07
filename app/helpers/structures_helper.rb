module StructuresHelper

  # User string stored in structure model to retrieve subjects
  #
  # @return Array of Subject
  def root_subjects_from_string(structure)
    structure.parent_subjects_string.split(';').map{|subject_string__subject_slug| Subject.fetch_by_id_or_slug(subject_string__subject_slug.split(':').last) }
  end

  # User string stored in structure model to retrieve subjects
  #
  # @return Array of Subject
  def child_subjects_from_string(structure)
    structure.subjects_string.split(';').map{|subject_string__subject_slug| Subject.fetch_by_id_or_slug(subject_string__subject_slug.split(':').last) }.select{ |subj| subj.depth == 2 }
  end

  def response_time_in_words(structure)
    return unless structure.response_time
    date = Time.now - structure.response_time.to_i.hours
    distance_of_time_in_words_to_now(date).capitalize
  end

  # Use subject string stored in structure
  # @return Child subjects as text
  def join_child_subjects_text(structure)
    structure.subjects_name_as_string(:subjects_string).join(', ')
  end

  # Use subject string stored in structure
  # @return Parent subjects as text
  def join_parent_subjects_text(structure)
    structure.subjects_name_as_string(:parent_subjects_string).join(', ')
  end

  # Use subject string stored in structure
  # @return Course subjects as text
  def join_structure_course_subjects_text(structure)
    if structure.course_subjects_string.present?
      structure.subjects_name_as_string(:course_subjects_string).join(', ')
    else
      structure.subjects_name_as_string(:subjects_string).join(', ')
    end
  end

  def readable_phone_number phone_number
    if phone_number
      # Remove dashes
      _phone_number = phone_number.gsub(' ', '').gsub('-', '').gsub('.', '').gsub('+33', '0').gsub(/^33/, '0')
      return "#{_phone_number[0..1]} #{_phone_number[2..3]} #{_phone_number[4..5]} #{_phone_number[6..7]} #{_phone_number[8..9]}"
    end
    return nil
  end

  # @param distance decimal, eg. 1.4, 0.4, etc.
  #
  # @return 100m, 2.4km, etc.
  def readable_distance(distance)
    if distance < 1
      "#{(distance * 1000).round} m"
    else
      "#{distance} km"
    end
  end

  def structures_path_for_city_and_subject(city, subject=nil)
    begin
      subject = Subject.find(subject) if subject.is_a? String
    rescue
    end
    if subject.nil?
      root_search_page_without_subject_path(city)
    elsif subject.depth == 0
      root_search_page_path(subject, city)
    else
      search_page_path(subject.root, subject, city)
    end
  end

  # The little children of the structure.
  #
  # @return an Array of subjects.
  def little_children_subjects(structure)
    subjects = structure.subjects.little_children.uniq
    if subjects.empty?
      subjects = structure.subjects.roots.flat_map(&:little_children)
    end

    subjects
  end
end
