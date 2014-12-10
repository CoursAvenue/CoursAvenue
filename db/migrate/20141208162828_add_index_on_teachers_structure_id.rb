class AddIndexOnTeachersStructureId < ActiveRecord::Migration
  def change
    add_index :teachers, :structure_id
  end
end
