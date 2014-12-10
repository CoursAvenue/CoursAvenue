class AddIndexOnPlanningsCourseId < ActiveRecord::Migration
  def change
    add_index :plannings, :course_id
  end
end
