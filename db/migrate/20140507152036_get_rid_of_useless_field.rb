class GetRidOfUselessField < ActiveRecord::Migration

  def up
    remove_column :admins, :management_software_used
    remove_column :structures, :cancel_condition
    remove_column :structures, :modification_condition
  end

  def down
  end
end
