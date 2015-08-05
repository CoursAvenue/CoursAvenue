class AddCardLockToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :card_locked, :boolean, default: false
  end
end
