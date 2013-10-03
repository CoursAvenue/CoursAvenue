class Course::Workshop < Course

  def is_workshop?
    true
  end

  def type_name_html
    'Cours&#8209;atelier'.html_safe
  end

  def type_name
    'Cours-atelier'
  end

  def underscore_name
    'workshop'
  end

  def latest_end_date
    self.plannings.order.order('end_date DESC').first.try(:end_date)
  end
end
