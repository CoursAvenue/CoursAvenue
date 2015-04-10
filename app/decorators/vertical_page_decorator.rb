class VerticalPageDecorator < Draper::Decorator

  # Ex.:
  #   Cours de salsa à Paris
  #   Cours de salsa
  #   Cours de salsa - stages de salsa à Paris
  #   Cours de salsa - stages de salsa à Paris | CoursAvenue.com
  def page_title(city=nil)
    if object.page_title.present?
      object.page_title
    else
      if object.show_trainings_in_title?
        text = "Cours de #{object.subject_name.downcase} - stages de #{object.subject_name.downcase} #{(city ? "à #{city.name}" : '')}"
      else
        text = "Cours de #{object.subject_name.downcase} #{(city ? "à #{city.name}" : '')}"
      end
      # SEO Title is 75 max, if with adding ' | CoursAvenue' we are under 75, then we show it
      (text.length < 56 ? "#{text} | CoursAvenue.com" : text)
    end
  end

  def page_h1(city=nil)
    "#{object.title} #{(city ? "à #{city.name}" : '')}"
  end

  def link_text(city=nil)
    if object.show_trainings_in_title?
      "Cours de #{object.subject_name.downcase} - stages de #{object.subject_name.downcase} #{(city ? "à #{city.name}" : '')}"
    else
      "Cours de #{object.subject_name.downcase} #{(city ? "à #{city.name}" : '')}"
    end
  end
end
