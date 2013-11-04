class RenameTeachersAtHomeIntoTeachesAtHome < ActiveRecord::Migration
  def change
    rename_column :structures, :teachers_at_home, :teaches_at_home
  end
end
