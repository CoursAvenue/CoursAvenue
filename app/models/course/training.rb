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

  def type_name
    'Stage'
  end

  def self.underscore_name
    'training'
  end

  def underscore_name
    self.class.underscore_name
  end

  def latest_end_date
    self.plannings.order('end_date DESC').first.try(:end_date)
  end

  def expired?
    return true if plannings.empty?
    (plannings.map(&:end_date).compact.sort.last || Date.yesterday) < Date.today
  end

  def can_be_published?
    plannings.future.any? and price_group.present?
  end
end
