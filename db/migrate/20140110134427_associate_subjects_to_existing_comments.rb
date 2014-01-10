class AssociateSubjectsToExistingComments < ActiveRecord::Migration
  def change
    bar = ProgressBar.new Comment.count
    Comment.find_each do |comment|
      bar.increment!
      if comment.user
        comment.subjects = comment.user.subjects
        comment.save
      end
    end
  end
end
