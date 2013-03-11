class Course::Training < Course

  def is_training?
    true
  end

  def length
    plannings.first.length
  end

  def type_name_html
    'Stage'
  end

  def type_name
    'Stage'
  end

  def slug_type_name
    'stage'
  end

  def underscore_name
    'training'
  end
end
