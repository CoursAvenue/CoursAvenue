class RemoveGivesProfessionalCoursesColumn < ActiveRecord::Migration
  def change
    remove_column :structures, :gives_professional_courses
  end
end
