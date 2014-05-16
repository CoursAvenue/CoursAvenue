class AddHighlightedCommentIdToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :highlighted_comment_id, :integer
  end
end
