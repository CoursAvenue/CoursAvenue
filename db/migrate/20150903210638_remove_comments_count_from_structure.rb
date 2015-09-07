class RemoveCommentsCountFromStructure < ActiveRecord::Migration
  def change
    remove_column :structures, :comments_count
  end
end
