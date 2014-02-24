module SubjectHelper

  def vertical_page_url_for(subject, city=nil)
    if city
      if subject.depth == 0
        return vertical_root_subject_city_path(subject, city)
      else
        return vertical_subject_city_path(subject.root, subject, city)
      end
    else
      if subject.depth == 0
        return vertical_root_subject_path(subject)
      else
        return vertical_subject_path(subject.root, subject)
      end
    end
  end

  def subject_image(subject)
    if subject.image?
      return subject.image.url(:small)
    elsif subject.parent and subject.parent.image?
      return subject.parent.image.url(:small)
    elsif subject.grand_parent and subject.grand_parent.image?
      return subject.grand_parent.image.url(:small)
    end
  end

  def subjects_name_from_string(subjects_string)
    subjects_string.split(';').collect do |subject_string|
      subject_string.split(':')[0]
    end.join(', ')
  end
end
