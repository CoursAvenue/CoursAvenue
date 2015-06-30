class UpdateDefaultEnableOnStructure < ActiveRecord::Migration
  def up
    change_column_default :structures, :enabled, true
  end

  def down
    change_column_default :structures, :enabled, false
  end
end
