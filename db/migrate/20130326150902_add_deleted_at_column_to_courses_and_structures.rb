class AddDeletedAtColumnToCoursesAndStructures < ActiveRecord::Migration
  def change
    add_column :structures, :deleted_at, :time
    add_column :courses, :deleted_at, :time
  end
end
