class AddSuperAdminToAdmin < ActiveRecord::Migration
  def change
    add_column :admin_users, :super_admin, :boolean, :default => false, :null => false
  end
end
