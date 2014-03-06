class StructureDecorator < Draper::Decorator

  def given_course_types
    types = []
    if object.teaches_at_home
      types << 'cours à domicile'
    end
    if object.gives_group_courses
      types << 'cours collectifs'
    end
    if object.gives_individual_courses
      types << 'cours individuels'
    end
    types.join(', ')
  end

end
