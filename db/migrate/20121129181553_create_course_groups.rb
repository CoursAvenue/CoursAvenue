class CreateCourseGroups < ActiveRecord::Migration
  def change
    create_table :course_groups do |t|
      t.string  :type
      t.string  :name

      t.references :structure
      t.references :discipline

      t.timestamps
    end
  end
end
