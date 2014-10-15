class StructureDecorator < Draper::Decorator

  def places_popover(places=nil)
    output = ''
    if object.is_sleeping?
      object.sleeping_attributes[:places].each do |place|
        output << "<div class='push-half--bottom'><strong>#{place['name']}</strong><br>#{place['street']}, #{City.find(place['city_id']).name}</div>"
      end
    else
      # Use find_by_id to prevent from exception when place is not find.
      # In this case: http://www.coursavenue.dev/etablissements/voix-et-voie/pass-decouverte place wasn't found...
      places ||= object.places
      places.each do |place|
        next if place.nil?
        output << "<div class='push-half--bottom'><strong>#{place.name}</strong><br>#{place.street}, #{place.city.name}</div>"
      end
    end
    output.html_safe
  end

  def courses_subjects_at_depth_2_count
    object.courses.available_in_discovery_pass.map(&:subjects).flatten.uniq.count
  end

  def subjects_at_depth_2_count
    if object.is_sleeping?
      object.subjects_string.split(';').map{|subject_string__subject_slug| Subject.fetch_by_id_or_slug(subject_string__subject_slug.split(':').last) }.select{ |subj| subj.depth == 2 }.length
    else
      object.subjects.at_depth(2).count
    end
  end

  def places_count
    if object.is_sleeping?
      object.sleeping_attributes[:places].length
    else
      object.places.count
    end
  end

  def courses_subjects_popover
    _subjects = []
    subjects_at_depth_0 = object.courses.map(&:subjects).flatten.map(&:root).uniq
    subjects_at_depth_2 = object.courses.map(&:subjects).flatten.uniq
    subjects_at_depth_0.uniq.each do |root_subject|
      subjects_at_depth_2 = object.subjects.at_depth(2)
      _child_subjects = subjects_at_depth_2.uniq.sort_by(&:name).select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      _subjects << {
        root_name: root_subject.name,
        child_names: _child_subjects.map(&:name),
        child_length: _child_subjects.length
      }
    end

    output = ''
    _subjects.sort{ |a, b| b[:child_length] <=> a[:child_length] }.each_with_index do |subject_hash, index|
      output << "<div class='#{index > 0 ? 'push-half--top' : ''}'><strong>#{subject_hash[:root_name]} #{subject_hash[:child_names].length > 0 ? ' :' : ''}</strong>"
      list_item_start = (subject_hash[:child_names].length > 1 ? '- ' : '')
      subject_hash[:child_names].each do |child_name|
        output << "<br>#{list_item_start}#{child_name}"
      end
      output << "</div>"
    end
    output.html_safe
  end

  def subjects_popover
    _subjects = []
    is_sleeping = object.is_sleeping?
    if is_sleeping
      subjects_at_depth_0 = object.parent_subjects_string.split(';').map{|subject_string__subject_slug| Subject.fetch_by_id_or_slug(subject_string__subject_slug.split(':').last) }
    else
      subjects_at_depth_0 = object.subjects.at_depth(0)
    end
    subjects_at_depth_0.uniq.each do |root_subject|
      if is_sleeping
        child_subjects = object.subjects_string.split(';').map{|subject_string__subject_slug| Subject.fetch_by_id_or_slug(subject_string__subject_slug.split(':').last) }.select{ |subj| subj.depth == 2 }
      else
        child_subjects = object.subjects.at_depth(2)
      end
      _child_subjects = child_subjects.uniq.sort_by(&:name).select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      _subjects << {
        root_name: root_subject.name,
        child_names: _child_subjects.map(&:name),
        child_length: _child_subjects.length
      }
    end

    output = ''
    _subjects.sort{ |a, b| b[:child_length] <=> a[:child_length] }.each_with_index do |subject_hash, index|
      output << "<div class='#{index > 0 ? 'push-half--top' : ''}'><strong>#{subject_hash[:root_name]} #{subject_hash[:child_names].length > 0 ? ' :' : ''}</strong>"
      list_item_start = (subject_hash[:child_names].length > 1 ? '- ' : '')
      subject_hash[:child_names].each do |child_name|
        output << "<br>#{list_item_start}#{child_name}"
      end
      output << "</div>"
    end
    output.html_safe
  end

  def given_funding_type
    object.funding_types.map{ |funding_type| I18n.t(funding_type.name)}.join(', ')
  end

  def promotion_popover
    courses = object.courses.lessons.select{ |course| course.is_published? and course.has_promotion? }
    courses = courses + object.courses.privates.select{ |course| course.is_published? and course.has_promotion? }
    output  = ''
    output  << "<div><strong>#{courses.length} #{'cours régulier'.pluralize(courses.length)} :</strong></div>" if courses.any?
    list_item_start = (courses.length > 1 ? '- ' : '')
    courses.each do |course|
      output << "<div>#{list_item_start}#{course.name}</div>"
    end
    trainings = object.courses.trainings.select{ |course| course.is_published? and course.has_promotion? }
    output  << "<div class='push-half--top'><strong>#{trainings.length} #{'stage'.pluralize(trainings.length)} :</strong></div>" if trainings.any?
    list_item_start = (trainings.length > 1 ? '- ' : '')
    trainings.each do |training|
      output << "<div>#{list_item_start}#{training.name}</div>"
    end
    output
  end

  def group_courses_popover(options={})
    courses = (options[:discovery_pass].present? ? object.courses.available_in_discovery_pass.lessons.reject{ |c| c.plannings.future.empty? } : object.courses.lessons.select(&:is_published?))
    output  = ''
    output  << "<div><strong>#{courses.length} #{'cours collectif'.pluralize(courses.length)} :</strong></div>" if courses.any?
    list_item_start = (courses.length > 1 ? '- ' : '')
    courses.each do |course|
      output << "<div>#{list_item_start}#{course.name}</div>"
    end
    trainings = (options[:discovery_pass].present? ? object.courses.available_in_discovery_pass.trainings.reject{ |c| c.plannings.future.empty? } : object.courses.trainings.select(&:is_published?))
    list_item_start = (trainings.length > 1 ? '- ' : '')
    output  << "<div class='#{courses.any? ? 'push-half--top' : ''}'><strong>#{trainings.length} #{'stage'.pluralize(trainings.length)} :</strong></div>" if trainings.any?
    trainings.each do |training|
      output << "<div>#{list_item_start}#{training.name}</div>"
    end
    output
  end

  def individual_courses_popover(options={})
    courses = (options[:discovery_pass].present? ? object.courses.available_in_discovery_pass.privates.reject{ |c| c.plannings.future.empty? } : object.courses.privates.select(&:is_published?))
    output  = "<div><strong>#{courses.length} #{'cours particulier'.pluralize(courses.length)} :</strong></div>" if courses.any?
    list_item_start = (courses.length > 1 ? '- ' : '')
    courses.each do |course|
      output << "<div>#{list_item_start}#{course.name}</div>"
    end
    output
  end

end
