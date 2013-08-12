module PlacesHelper

  def join_parent_subjects(place, with_h3 = false)
    place.parent_subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(',')
      content_tag(:li) do
        content_tag((with_h3 ? :h3: :span), class: 'flush--bottom inherit-font-size') do
          link_to subject_name, subject_places_path(subject_slug), class: 'lbl milli inline subject-link'
        end
      end
    end.join(' ').html_safe
  end

  def join_parent_subjects_text(place)
    place.parent_subjects_string.split(';').collect do |subject_string|
      subject_string.split(',')[0]
    end.join(', ').html_safe
  end

  def join_child_subjects(place, with_h3 = false)
    place.subjects_string.split(';').collect do |subject_string|
      subject_name, subject_slug = subject_string.split(',')
      content_tag(:li) do
        content_tag((with_h3 ? :h3: :span), class: 'flush--bottom inherit-font-size') do
          link_to subject_name, subject_places_path(subject_slug), class: 'lbl milli inline subject-link'
        end
      end
    end.join(' ').html_safe
  end

  def join_child_subjects_text(place)
    place.subjects_string.split(';').collect do |subject_string|
      subject_string.split(',')[0]
    end.join(', ').html_safe
  end

  def short_address(place)
    "#{place.city.name}"
  end

  def readable_address(place)
    address = ""
    address << content_tag(:span, itemprop: 'address', itemscope: true, itemtype: 'http://schema.org/PostalAddress') do
      inner_address = ''
      inner_address << content_tag(:span, place.street, itemprop: 'streetAddress')
      inner_address << ', '
      inner_address << content_tag(:span, place.city.name, itemprop: 'addressLocality')
      inner_address.html_safe
    end
    address.html_safe
  end
end
