class CreateUsersFromCommentEmail < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Comment.count
    Comment.find_each do |comment|
      bar.increment!
      if User.where(email: comment.email).empty?
        user = User.new email: comment.email, name: comment.author_name, active: false
        user.structures << comment.structure
        user.subjects << comment.structure.subjects
        user.save
      end
    end
  end

  def down
  end
end
