class AddIndexOnCourseStructureIdAndActive < ActiveRecord::Migration
  def change
    add_index :courses, :structure_id
    add_index :courses, :active
  end
end
