class AddEnableFlagToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :enabled, :boolean, default: false
  end
end
