class AddDefaultToCrmLocked < ActiveRecord::Migration
  def up
    change_column_default :crm_locks, :locked, false
  end

  def down
    change_column_default :crm_locks, :locked, nil
  end
end
