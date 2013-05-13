class AddCommentToStructure < ActiveRecord::Migration
  def change
    add_column :structures, :rating, :decimal
    Comment.where{commentable_type == 'Place'}.all.each do |comment|
      comment.commentable_id   = comment.commentable.structure.id
      comment.commentable_type = 'Structure'
      comment.save
    end
    remove_column :places, :rating
  end
end
