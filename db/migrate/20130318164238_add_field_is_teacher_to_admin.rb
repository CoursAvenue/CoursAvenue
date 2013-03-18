class AddFieldIsTeacherToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :is_teacher, :boolean
  end
end
