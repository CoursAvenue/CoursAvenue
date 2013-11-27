class AddCourseNamesToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :course_names, :text
    bar = ProgressBar.new Structure.count
    Structure.find_each do |structure|
      bar.increment!
      structure.update_column :course_names, structure.courses.map(&:name).uniq.join(', ')
    end
  end
end
