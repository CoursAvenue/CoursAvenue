class Course::Lesson < Course

  ######################################################################
  # Validations                                                        #
  ######################################################################
  validate :end_date_in_future

  def is_lesson?
    true
  end

  def type_name
    'Cours collectif'
  end

  def self.underscore_name
    'lesson'
  end

  def underscore_name
    self.class.underscore_name
  end

  def latest_end_date
    self.end_date
  end

  def expired?
    return false
  end

  private
  # Add errors if end date is not in the future
  #
  # @return [type] [description]
  def end_date_in_future
    if end_date and end_date < Date.today
      errors.add(:end_date, 'Le cours ne peut pas être dans le passé.')
    end
  end
end
