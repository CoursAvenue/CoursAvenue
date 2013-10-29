class RemoveQuotesFromExistingCommentTitle < ActiveRecord::Migration
  def up
    bar = ProgressBar.new Comment.where{title != nil}.count
    Comment.where{title != nil}.each do |comment|
      bar.increment!
      comment.send :remove_quotes_from_title
      comment.save(validate: false)
    end
  end

  def down
  end
end
