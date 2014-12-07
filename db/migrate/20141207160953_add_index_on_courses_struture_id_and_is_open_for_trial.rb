class AddIndexOnCoursesStrutureIdAndIsOpenForTrial < ActiveRecord::Migration
  def change
    add_index :courses, [:structure_id, :is_open_for_trial]
  end
end
