class CreateTeachersAndAffectToPlanning < ActiveRecord::Migration
  def up
    Planning.all.each do |planning|
      if planning.teacher_name.present?
        unless planning.structure.nil?
          planning_structure_id = planning.structure.id
          planning_teacher_name = planning.teacher_name
          teachers = Teacher.where{(structure_id == planning_structure_id) & (name == planning_teacher_name)}
          if teachers.any?
            planning.teacher = teachers.first
          else
            teacher = Teacher.new(name: planning.teacher_name)
            teacher.structure = planning.structure
            teacher.save
            planning.teacher  = teacher
          end
          planning.save
        end
      end
    end
  end

  def down
    Teacher.delete_all
  end
end
