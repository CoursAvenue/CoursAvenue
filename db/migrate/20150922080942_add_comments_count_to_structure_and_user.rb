class AddCommentsCountToStructureAndUser < ActiveRecord::Migration
  def change
    add_column :structures, :comments_count, :integer
  end
end
