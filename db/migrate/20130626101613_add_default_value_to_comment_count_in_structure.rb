class AddDefaultValueToCommentCountInStructure < ActiveRecord::Migration
  def up
    Structure.where{comments_count == nil}.all.map{ |structure| structure.comments_count = 0; structure.save }
    change_column :structures, :comments_count, :integer, default: 0
  end

  def down
    change_column :structures, :comments_count, :integer, default: nil
  end
end
