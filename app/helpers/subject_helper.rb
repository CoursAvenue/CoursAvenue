module SubjectHelper
  def subjects_name_from_string(subjects_string)
    subjects_string.split(';').collect do |subject_string|
      subject_string.split(',')[0]
    end.join(', ')
  end
end
