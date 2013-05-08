class RemoveTeacherNameFromPlanning < ActiveRecord::Migration
  def up
    remove_column :plannings, :teacher_name
  end

  def down
    add_column :plannings, :teacher_name, :string
  end
end
