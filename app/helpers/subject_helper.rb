module SubjectHelper

  def vertical_page_url_for(subject, city=nil)
    if city
      if subject.depth == 0
        return vertical_root_subject_city_url(subject, city, subdomain: 'www')
      else
        return vertical_subject_city_url(subject.root, subject, city, subdomain: 'www')
      end
    else
      if subject.depth == 0
        return vertical_root_subject_url(subject, subdomain: 'www')
      else
        return vertical_subject_url(subject.root, subject, subdomain: 'www')
      end
    end
  end

  def subject_image(subject)
    if subject.image?
      return subject.image
    elsif subject.parent and subject.parent.image?
      return subject.parent.image
    elsif subject.grand_parent and subject.grand_parent.image?
      return subject.grand_parent.image
    end
  end

  def subjects_name_from_string(subjects_string)
    subjects_string.split(';').collect do |subject_string|
      subject_string.split(':')[0]
    end.join(', ')
  end
end
