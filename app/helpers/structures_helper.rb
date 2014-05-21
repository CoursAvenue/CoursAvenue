module StructuresHelper

  def response_time_in_words(structure)
    return unless structure.response_time
    date = Time.now - structure.response_time.to_i.hours
    distance_of_time_in_words_to_now(date).capitalize
  end

  def share_jpo_page_url(structure, provider = :facebook)
    summary = "Je participe aux Journées Portes Ouvertes de CoursAvenue des 5-6 avril en Ile-de-France. N'hésitez pas à vous inscrire gratuitement et à pofiter des ateliers gratuits que je propose."
    case provider
    when :facebook
      URI.encode("http://www.facebook.com/sharer.php?s=100&p[title]=Retrouvez les ateliers gratuits que je donne aux Journées Portes Ouvertes CoursAvenue&p[url]=#{jpo_structure_url(structure, subdomain: 'www')}&p[summary]=#{summary}")
    when :twitter
      URI.encode("https://twitter.com/intent/tweet?text=Je propose des ateliers gratuits pour les Journées Portes Ouvertes CoursAvenue #{structure.name}&via=CoursAvenue&hashtags=JPO14&url=#{jpo_structure_url(structure, subdomain: 'www')}")
    end
  end

  def join_child_subjects(structure, with_h3 = false)
    structure.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      content_tag(:li) do
        content_tag((with_h3 ? :h3: :span), class: 'flush--bottom inherit-font-size') do
          link_to subject_name, structures_path(name: subject_name), class: 'lbl milli inline subject-link'
        end
      end
    end.uniq.join(' ').html_safe
  end

  def join_child_subjects_text(structure)
    structure.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      subject_name
    end.uniq.join(', ').html_safe
  end

  def join_parent_subjects(structure, with_h3 = false)
    structure.parent_subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(':')
      content_tag(:li) do
        content_tag((with_h3 ? :h3: :span), class: 'flush--bottom inherit-font-size') do
          link_to subject_name, structures_path(name: subject_name), class: 'lbl milli inline subject-link'
        end
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
      _phone_number = phone_number.gsub(' ', '').gsub('.', '').gsub('+33', '0')
      "#{_phone_number[0..1]} #{_phone_number[2..3]} #{_phone_number[4..5]} #{_phone_number[6..7]} #{_phone_number[8..9]}"
    end
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
end
