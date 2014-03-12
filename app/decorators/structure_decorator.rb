class StructureDecorator < Draper::Decorator

  def given_course_types
    types = []
    if object.teaches_at_home
      if object.teaches_at_home_radius.present?
        types << "cours à domicile (#{object.teaches_at_home_radius})"
      else
        types << "cours à domicile"
      end
    end
    if object.gives_group_courses
      types << 'cours collectifs'
    end
    if object.gives_individual_courses
      types << 'cours individuels'
    end
    types.join(', ').capitalize
  end

  def given_funding_type
    object.funding_types.map{ |funding_type| I18n.t(funding_type.name)}.join(', ')
  end
end
