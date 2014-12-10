class AddIndexOnAdminsForStructureId < ActiveRecord::Migration
  def change
    add_index :admins, :structure_id
  end
end
