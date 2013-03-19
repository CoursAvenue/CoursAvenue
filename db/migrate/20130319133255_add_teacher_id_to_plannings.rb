class AddTeacherIdToPlannings < ActiveRecord::Migration
  def change
    add_column :plannings, :teacher_id, :integer
  end
end
