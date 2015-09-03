class VerticalPageDecorator < Draper::Decorator

  def page_meta_description(city=nil, neighborhood=nil)
    if neighborhood
      "#{page_h1} à #{neighborhood.name} - #{city.name} #{city.zip_code} : toutes les écoles de #{object.subject_name.downcase} à #{city.name}, stages, cours d'essai gratuits, plannings, tarifs, conseils, avis, promotions"
    elsif city
      "#{page_h1} à #{city.name} - #{city.department_code} : toutes les écoles de #{object.subject_name.downcase} à #{city.name}, stages, cours d'essai gratuits, plannings, tarifs, conseils, avis, promotions"
    else
      "#{page_h1} : toutes les cours de #{object.subject_name.downcase}, stages, cours d'essai gratuits, plannings, tarifs, conseils, avis, promotions"
    end
  end

  # Ex.:
  #   Cours de salsa à Paris
  #   Cours de salsa
  #   Cours de salsa - stages de salsa à Paris
  #   Cours de salsa - stages de salsa à Paris | CoursAvenue.com
  def page_title(city=nil, neighborhood=nil)
    place_end_string = ''
    if neighborhood
      place_end_string = " à #{neighborhood.name} (#{city.name} - #{city.zip_code})"
    elsif city
      place_end_string = " à #{city.name}"
    end
    if object.page_title.present?
      "#{object.page_title} #{place_end_string}".strip
    else
      if object.show_trainings_in_title?
        text = "Cours de #{object.subject_name.downcase} - stages de #{object.subject_name.downcase} #{place_end_string}"
      else
        text = "Cours de #{object.subject_name.downcase} #{place_end_string}"
      end
      # SEO Title is 75 max, if with adding ' | CoursAvenue' we are under 75, then we show it
      (text.length < 56 ? "#{text} | CoursAvenue.com" : text)
    end
  end

  def page_h1(city=nil, neighborhood=nil)
    if neighborhood
      "#{object.title} à #{neighborhood.name}"
    else
      "#{object.title} #{(city ? "à #{city.name}" : '')}"
    end
  end


  def button(subject, city=nil, neighborhood=nil, large=false)
    h.link_to search_link(subject, city, neighborhood), class: 'btn btn--blue-green btn--large see-all-courses-tracker'do
      if neighborhood
        "<i class=\"fa fa-map-marker\"></i> Voir les cours à #{neighborhood.name} (#{city.name})".html_safe
      else
        if large and city
          zip_code = (city.size == 3 ? city.department_code : city.zip_code)
        end
        "<i class=\"fa fa-map-marker\"></i> Voir les cours #{city ? "à #{city.name}" : 'autour de moi'} #{zip_code}".html_safe
      end
    end
  end

  def search_link(subject, city=nil, neighborhood=nil)
    if subject.root?
      h.root_search_page_path(subject.root, (city || 'paris'), locate_user: (city ? '' : 'on'))
    else
      h.search_page_path(subject.root, subject, (city || 'paris'), locate_user: (city ? '' : 'on'))
    end
  end

  def metro_search_link(subject, city=nil, neighborhood=nil, metro_stop)
    if subject.root?
      h.root_search_page_path(subject.root, (city || 'paris'), metro_stop: metro_stop.slug)
    else
      h.search_page_path(subject.root, subject, (city || 'paris'), metro_stop: metro_stop.slug)
    end
  end

  def link_text(city=nil)
    if object.show_trainings_in_title?
      "Cours de #{object.subject_name.downcase} - stages de #{object.subject_name.downcase} #{(city ? "à #{city.name}" : '')}"
    else
      "Cours de #{object.subject_name.downcase} #{(city ? "à #{city.name}" : '')}"
    end
  end
end
