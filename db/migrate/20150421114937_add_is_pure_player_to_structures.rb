class AddIsPurePlayerToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :pure_player, :boolean, default: false
  end
end
