class StructureDecorator < Draper::Decorator

  def given_course_types
    types = []
    if object.teaches_at_home
      if object.teaches_at_home and object.places.homes.any?
        if object.places.homes.first.radius.present?
          types << "cours à domicile (#{object.places.homes.first.radius})"
        else
          types << "cours à domicile"
        end
      end
    end
    if object.gives_group_courses
      types << 'cours collectifs'
    end
    if object.gives_individual_courses
      types << 'cours individuels'
    end
    types.join(', ')
  end

  def given_funding_type
    object.funding_types.map{ |funding_type| I18n.t(funding_type.name)}.join(', ')
  end
end
