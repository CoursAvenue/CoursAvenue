module StructuresHelper

  def root_subjects_from_string(structure)
    structure.parent_subjects_string.split(';').map{|subject_string__subject_slug| Subject.find(subject_string__subject_slug.split(':').last) }
  end

  def child_subjects_from_string(structure)
    structure.subjects_string.split(';').map{|subject_string__subject_slug| Subject.find(subject_string__subject_slug.split(':').last) }.select{ |subj| subj.depth == 2 }
  end

  def header_promotion_title_for_structure(structure)
    if structure.has_free_trial_course? and structure.has_promotion?
      "Essai gratuit & promotions"
    elsif structure.has_promotion?
      "Promotions"
    elsif structure.has_free_trial_course?
      "Essai gratuit"
    else
      nil
    end
  end

  def response_time_in_words(structure)
    return unless structure.response_time
    date = Time.now - structure.response_time.to_i.hours
    distance_of_time_in_words_to_now(date).capitalize
  end

  def share_jpo_page_url(structure, provider = :facebook)
    summary = "Je participe aux Journées Portes Ouvertes de CoursAvenue des 5-6 avril en Ile-de-France. N'hésitez pas à vous inscrire gratuitement et à pofiter des ateliers gratuits que je propose."
    case provider
    when :facebook
      URI.encode("http://www.facebook.com/sharer.php?s=100&p[title]=Retrouvez les ateliers gratuits que je donne aux Journées Portes Ouvertes CoursAvenue&p[url]=#{jpo_structure_url(structure, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)}&p[summary]=#{summary}")
    when :twitter
      URI.encode("https://twitter.com/intent/tweet?text=Je propose des ateliers gratuits pour les Journées Portes Ouvertes CoursAvenue #{structure.name}&via=CoursAvenue&hashtags=JPO14&url=#{jpo_structure_url(structure, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN)}")
    end
  end

  def join_child_subjects(structure)
    structure.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      content_tag :span, class: 'lbl lbl--small', style: 'margin-bottom: 2px;' do
        subject_name
      end
    end.uniq.join(' ').html_safe
  end

  def join_child_subjects_text(structure)
    structure.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      subject_name
    end.uniq.join(', ').html_safe
  end

  def join_parent_subjects(structure)
    structure.parent_subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      content_tag :span, class: 'lbl lbl--small', style: 'margin-bottom: 2px;' do
        subject_name
      end
    end.uniq.join(' ').html_safe
  end

  def join_parent_subjects_text(structure)
    structure.parent_subjects_string.split(';').collect do |subject_string|
      subject_string.split(':')[0]
    end.uniq.join(', ').html_safe
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

  def subject_roots_ordered(structure)
    _subjects = []
    structure.subjects.at_depth(0).uniq.each do |root_subject|
      child_subjects = structure.subjects.at_depth(2).uniq.order('name ASC').select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      _subjects << {
        root: root_subject,
        child_length: child_subjects.length
      }
    end
    _subjects.sort{ |subj| subj[:child_length] }.reverse.map{ |subj| subj[:root] }
  end

  def structures_path_for_city_and_subject(city, subject)
    if subject.depth == 0
      structures_path(lat: city.latitude, lng: city.longitude, address_name: city.name, root_subject_id: subject.root.slug)
    elsif subject.depth == 1
      structures_path(lat: city.latitude, lng: city.longitude, address_name: city.name, root_subject_id: subject.root.slug, parent_subject_id: subject.slug)
    else
      structures_path(lat: city.latitude, lng: city.longitude, address_name: city.name, root_subject_id: subject.root.slug, parent_subject_id: subject.parent.slug, subject_id: subject.slug)
    end
  end
end
