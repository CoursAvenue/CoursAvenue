class AddSleepingStructureToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :sleeping_structure_id, :integer
  end
end
