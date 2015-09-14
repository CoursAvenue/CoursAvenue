class StructureDecorator < Draper::Decorator

  delegate_all

  def avatar(size=60)
    if object.logo.present?
      h.image_tag object.logo.url(:thumb), class: 'rounded--circle block center-block bordered', width: size, height: size
    else
      h.content_tag('div', '', class: "comment-avatar-#{size}")
    end
  end

  def structure_type
    I18n.t(object.structure_type) if object.structure_type.present? and object.structure_type != 'structures.other'
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

  # @return something like:
  #   06 07 65 33 23
  #   <br>
  #   nim.izadi@gmail.com
  # Structure's phone numbers
  def phone_numbers(with_info=true)
    phone_number_html = object.phone_numbers.map do |phone_number, index|
      phone_number_html = PhoneNumberDecorator.new(PhoneNumber.new(number: phone_number.number)).formatted_number if phone_number.number
      phone_number_html = "<span class='nowrap'>#{phone_number_html}</span>"
      phone_number_html << " (#{phone_number.info})" if phone_number.info.present? and with_info
      "<span class='push-half--right'>#{phone_number_html}</span>"
    end.join(' ')
    phone_number_html.html_safe
  end

  # Link of structure's website
  def website_link
    if object.website.present?
      h.link_to 'Site Internet', URLHelper.fix_url(object.website), target: '_blank', rel: 'nofollow'
    end
  end

  # Check if a structure only has regular classes.
  #
  # @return a boolean
  def only_has_regular_classes?
    object.courses.pluck(:type).all? { |class_type| class_type != 'Course::Training' }
  end

  def about
    I18n.t("structures.structure_type_contact.#{(object.structure_type.present? ? object.structure_type : 'structures.other')}")
  end

  def search_url
    h.root_search_page_without_subject_url(object.dominant_city || 'paris', zoom: '15', discipline: object.name, subdomain: 'www')
  end
end
