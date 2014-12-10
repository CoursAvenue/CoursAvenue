class AddSleepingLogoToStructures < ActiveRecord::Migration
  def change
    add_attachment :structures, :sleeping_logo
  end
end
