class UpdateDefaultEnableOnStructure < ActiveRecord::Migration
  def up
    change_column_default :structures, :enabled, true
    Structure.update_all(enabled: true)
  end

  def down
    change_column_default :structures, :enabled, false
    Structure.update_all(enabled: false)
  end
end
