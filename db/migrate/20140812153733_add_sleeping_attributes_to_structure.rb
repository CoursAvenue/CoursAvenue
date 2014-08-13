class AddSleepingAttributesToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :sleeping_attributes, :text
  end
end
