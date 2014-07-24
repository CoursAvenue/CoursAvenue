class StructureDecorator < Draper::Decorator

  def places_popover
    output = ''
    object.places.each do |place|
      output << "<div class='flexbox'><div class='flexbox__item v-top'><strong>#{place.name}&nbsp;:&nbsp;</strong></div><div class='flexbox__item'>#{place.street}, #{place.city.name}</div></div>"
    end
    output.html_safe
  end

  def subjects_popover
    output = ''
    object.subjects.at_depth(0).each do |root_subject|
      child_subjects = object.subjects.at_depth(2).order('name ASC').select{ |subject|  subject.ancestry.start_with?(root_subject.id.to_s) }
      if child_subjects.any?
        output << <<-eos
          <div class='push-half--bottom'>
            <strong>#{root_subject.name}</strong>
            <br>
            #{child_subjects.map(&:name).join(', ')}
          </div>
        eos
      end
    end
    output.html_safe
  end

  def given_funding_type
    object.funding_types.map{ |funding_type| I18n.t(funding_type.name)}.join(', ')
  end
end
