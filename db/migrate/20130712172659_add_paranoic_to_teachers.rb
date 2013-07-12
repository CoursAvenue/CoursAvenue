class AddParanoicToTeachers < ActiveRecord::Migration
  def change
    add_column :teachers, :deleted_at, :time
  end
end
