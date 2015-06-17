class RemovePlanningIdFromIndexableCards < ActiveRecord::Migration
  def up
    remove_column :indexable_cards, :planning_id
  end

  def down
    add_column :indexable_cards, :planning_id, :integer
  end
end
