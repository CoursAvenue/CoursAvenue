class MoveCourseCommentsToStructure < ActiveRecord::Migration
  def up
    Comment.where{commentable_type == 'Course'}.each do |comment|
      if comment.commentable.nil?
        comment.delete
      else
        structure                 = comment.commentable.structure
        comment.title             = comment.commentable.name if comment.title.empty?
        comment.commentable_type  = 'Structure'
        comment.commentable_id    = structure.id
        comment.save
      end
    end
  end

  def down
  end
end
