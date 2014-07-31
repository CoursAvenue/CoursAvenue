class StructureDecorator < Draper::Decorator

  def places_popover
    output = ''
    object.places.each do |place|
      output << "<div class='push-half--bottom'><strong>#{place.name}</strong><br>#{place.street}, #{place.city.name}</div>"
    end
    output.html_safe
  end

  def subjects_popover
    _subjects = []
    object.subjects.at_depth(0).uniq.each do |root_subject|
      child_subjects = object.subjects.at_depth(2).uniq.order('name ASC').select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      _subjects << {
        root_name: root_subject.name,
        child_names: child_subjects.map(&:name),
        child_length: child_subjects.length
      }
    end

    output = ''
    _subjects.sort{ |a, b| b[:child_length] <=> a[:child_length] }.each do |subject_hash|
      output << "<div class='push-half--bottom'><strong>#{subject_hash[:root_name]} :</strong>"
      subject_hash[:child_names].each do |child_name|
        output << "<br>- #{child_name}"
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
    output  = "<div><strong>#{courses.length} #{'cours régulier'.pluralize(courses.length)} :</strong></div>"
    courses.each do |course|
      output << "<div>- #{course.name}</div>"
    end
    trainings = object.courses.trainings.select{ |course| course.is_published? and course.has_promotion? }
    output  << "<div class='push-half--top'><strong>#{trainings.length} #{'stage'.pluralize(trainings.length)} :</strong></div>"
    trainings.each do |training|
      output << "<div>- #{training.name}</div>"
    end
    output
  end

  def group_courses_popover
    courses = object.courses.lessons.select(&:is_published?)
    output  = "<div><strong>#{courses.length} #{'cours collectif'.pluralize(courses.length)} :</strong></div>" if courses.any?
    courses.each do |course|
      output << "<div>- #{course.name}</div>"
    end
    trainings = object.courses.trainings.select(&:is_published?)
    output  << "<div class='#{courses.any? ? 'push-half--top' : ''}'><strong>#{trainings.length} #{'stage'.pluralize(trainings.length)} :</strong></div>" if trainings.any?
    trainings.each do |training|
      output << "<div>- #{training.name}</div>"
    end
    output
  end

  def individual_courses_popover
    courses = object.courses.privates.select(&:is_published?)
    output  = "<div><strong>#{courses.length} #{'cours particulier'.pluralize(courses.length)} :</strong></div>"
    courses.each do |course|
      output << "<div>- #{course.name}</div>"
    end
    output
  end

end
