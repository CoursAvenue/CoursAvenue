class RemoveCardLockedFromStructures < ActiveRecord::Migration
  def change
    remove_column :structures, :card_locked
  end
end
