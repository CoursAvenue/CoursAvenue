class StructureDecorator < Draper::Decorator

  def structure_type
    I18n.t(object.structure_type) if object.structure_type.present? and object.structure_type != 'object.structure_type'
  end

  def all_subjects_slugs
    root_subject_slugs     = object.parent_subjects_string.split(';').map{|string| string.split(':')}.map(&:last)
    children_subject_slugs = object.subjects_string.split(';').map{|string| string.split(':')}.map(&:last)
    root_subject_slugs + children_subject_slugs
  end

  def places_popover
    output = ''
    # Use find_by_id to prevent from exception when place is not find.
    # In this case: http://www.coursavenue.dev/etablissements/voix-et-voie/pass-decouverte place wasn't found...
    object.places.includes(:city).each do |place|
      next if place.nil?
      output << "<div class='push-half--bottom'><strong>#{place.name}</strong><br>#{place.street}, #{place.city.name}</div>"
    end
    output.html_safe
  end

  def courses_subjects_at_depth_2_count
    object.courses.trial_courses.map(&:subjects).flatten.uniq.count
  end

  def subjects_at_depth_2_count
    object.subjects.at_depth(2).count
  end

  def places_count
    object.places.count
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
    subjects_at_depth_0 = object.subjects.at_depth(0)
    subjects_at_depth_0.uniq.each do |root_subject|
      child_subjects = object.subjects.at_depth(2)
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
    courses = object.courses.regulars.select{ |course| course.has_promotion? }
    output  = ''
    output  << "<div><strong>#{courses.length} #{'cours régulier'.pluralize(courses.length)} :</strong></div>" if courses.any?
    list_item_start = (courses.length > 1 ? '- ' : '')
    courses.each do |course|
      output << "<div>#{list_item_start}#{course.name}</div>"
    end
    trainings = object.courses.trainings.select{ |course| course.has_promotion? }
    output  << "<div class='push-half--top'><strong>#{trainings.length} #{'stage'.pluralize(trainings.length)} :</strong></div>" if trainings.any?
    list_item_start = (trainings.length > 1 ? '- ' : '')
    trainings.each do |training|
      output << "<div>#{list_item_start}#{training.name}</div>"
    end
    output
  end

  def trial_courses_popover
    courses = object.courses.open_for_trial.regulars
    output  = ''
    header_policy = I18n.t("structures.trial_courses_policy.#{object.trial_courses_policy}_nb_given")
    output  << "<div class='push-half--bottom'><strong>#{header_policy}</strong></div>"
    output  << "<div><strong>#{courses.length} #{'cours régulier'.pluralize(courses.length)} :</strong></div>" if courses.any?
    list_item_start = (courses.length > 1 ? '- ' : '')
    courses.each do |course|
      output << "<div>#{list_item_start}#{course.name}</div>"
    end
    trainings = object.courses.open_for_trial.trainings
    output  << "<div class='push-half--top'><strong>#{trainings.length} #{'stage'.pluralize(trainings.length)} :</strong></div>" if trainings.any?
    list_item_start = (trainings.length > 1 ? '- ' : '')
    trainings.each do |training|
      output << "<div>#{list_item_start}#{training.name}</div>"
    end
    output
  end

  def group_courses_popover(options={})
    courses = object.courses.lessons
    output  = ''
    output  << "<div><strong>#{courses.length} #{'cours collectif'.pluralize(courses.length)} :</strong></div>" if courses.any?
    list_item_start = (courses.length > 1 ? '- ' : '')
    courses.each do |course|
      output << "<div>#{list_item_start}#{course.name}</div>"
    end
    trainings = object.courses.trainings
    list_item_start = (trainings.length > 1 ? '- ' : '')
    output  << "<div class='#{courses.any? ? 'push-half--top' : ''}'><strong>#{trainings.length} #{'stage'.pluralize(trainings.length)} :</strong></div>" if trainings.any?
    trainings.each do |training|
      output << "<div>#{list_item_start}#{training.name}</div>"
    end
    output
  end

  def individual_courses_popover(options={})
    courses = object.courses.privates
    output  = "<div><strong>#{courses.length} #{'cours particulier'.pluralize(courses.length)} :</strong></div>" if courses.any?
    list_item_start = (courses.length > 1 ? '- ' : '')
    courses.each do |course|
      output << "<div>#{list_item_start}#{course.name}</div>"
    end
    output
  end

  # @param crypted=false Wether we have to show crypted number.
  #
  # @return something like:
  #   06 07 65 33 23
  #   <br>
  #   nim.izadi@gmail.com
  # And if crypted:
  #   XX XX XX XX 23
  #   <br>
  #   XXXXXXXXX@gmail.com
  # Structure's phone numbers
  def phone_numbers(crypted=false, on_one_line=false)
    phone_number_html = ''
    object.phone_numbers.each_with_index do |phone_number, index|
      if index > 0
        phone_number_html << "<br>" if on_one_line
        phone_number_html << ", " if !on_one_line
      end
      if crypted
        phone_number_html << "XX XX XX XX #{phone_number.number[-2..-1]}" if phone_number.number
      else
        phone_number_html << phone_number.number if phone_number.number
      end
    end
    phone_number_html.html_safe
  end

  # def phone_numbers
  #   string = ''
  #   object.phone_numbers.each do |phone_number|
  #     _phone_number = phone_number.number.gsub(' ', '').gsub('-', '').gsub('.', '').gsub('+33', '0').gsub(/^33/, '0')
  #     string << "<div>#{_phone_number[0..1]} #{_phone_number[2..3]} #{_phone_number[4..5]} #{_phone_number[6..7]} #{_phone_number[8..9]}</div>"
  #   end
  #   string.html_safe
  # end

  # Link of structure's website
  def website_link(truncate_length=100)
    h.link_to h.truncate(object.website, length: truncate_length), object.website, target: '_blank', rel: 'nofollow'
  end
end
