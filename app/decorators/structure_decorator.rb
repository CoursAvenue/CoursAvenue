class StructureDecorator < Draper::Decorator

  def places_popover
    output = ''
    object.places.each do |place|
      output << "<div class='push-half--bottom'><strong>#{place.name}</strong><br>#{place.street}, #{place.city.name}</div>"
    end
    output.html_safe
  end

  def subjects_popover
    _subjects = []
    object.subjects.at_depth(0).uniq.each do |root_subject|
      child_subjects = object.subjects.at_depth(2).uniq.order('name ASC').select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      _subjects << {
        root_name: root_subject.name,
        child_names: child_subjects.map(&:name).join(', '),
        child_length: child_subjects.length
      }
    end

    output = ''
    _subjects.sort{ |a, b| b[:child_length] <=> a[:child_length] }.each do |subject_hash|
      output << <<-eos
        <div class='push-half--bottom'>
          <strong>#{subject_hash[:root_name]} :</strong>
          <br>
          #{subject_hash[:child_names]}
        </div>
      eos
    end
    output.html_safe
  end

  def given_funding_type
    object.funding_types.map{ |funding_type| I18n.t(funding_type.name)}.join(', ')
  end
end
