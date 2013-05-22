class Course::Training < Course

  def is_training?
    true
  end

  def length
    if plannings.any?
      plannings.first.length
    end
      0
    else
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
