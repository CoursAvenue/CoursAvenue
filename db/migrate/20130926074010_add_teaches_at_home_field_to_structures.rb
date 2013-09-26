class AddTeachesAtHomeFieldToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :teachers_at_home, :boolean, default: false
  end
end
