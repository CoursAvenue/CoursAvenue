class CreateAdminUsersStructuresJoinTable < ActiveRecord::Migration
  def change
    create_table :admin_users_structures, :id => false do |t|
      t.references :admin_user, :structure
    end
    add_index :admin_users_structures, [:admin_user_id, :structure_id]
  end
end

