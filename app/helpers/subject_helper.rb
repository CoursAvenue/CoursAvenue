module SubjectHelper

  def vertical_page_url_for(subject)
    page = VerticalPage.where(subject_id: subject.id).first
    if page
      vertical_page_url(page.subject.root, page, subdomain: 'www')
    else
      root_url(subdomain: 'www')
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
