class RemoveUnusedFieldFromAdmins < ActiveRecord::Migration
  def change
    remove_column :admins, :active
    remove_column :admins, :role
    remove_column :admins, :is_teacher
  end
end
