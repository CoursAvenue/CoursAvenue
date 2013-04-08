class RemoveCommentFromStructure < ActiveRecord::Migration
  def up
    remove_column :structures, :rating
  end

  def down
    add_column :structures, :rating, :decimal
  end
end
