class AddCommentCountToStructure < ActiveRecord::Migration
  def up
    add_column :structures, :comments_count, :integer
    bar = ProgressBar.new Structure.count
    Structure.all.each do |structure|
      if structure.all_comments.length > 0
        structure.update_column :comments_count, structure.all_comments.length
      end
      bar.increment! 1
    end
  end

  def down
    remove_column :structures, :comments_count
  end
end
