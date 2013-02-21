class AddStructureIdToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :structure_id, :integer
  end
end
