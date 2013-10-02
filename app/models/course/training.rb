class Course::Training < Course

  def is_training?
    true
  end

  def length
    if plannings.any?
      plannings.first.length
    else
      0
    end
  end

  def type_name_html
    'Stage'
  end

  def type_name
    'Stage'
  end

  def underscore_name
    'training'
  end

  def latest_end_date
    self.plannings.order.order('end_date DESC').first.end_date
  end
end
