class Course::Workshop < Course

  def is_workshop?
    true
  end

  def type_name
    'Cours&#8209;atelier'.html_safe
  end

end
