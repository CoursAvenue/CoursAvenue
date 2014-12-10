class AddSlugOnComments < ActiveRecord::Migration
  def up
    add_column :comments, :slug, :string
    bar = ProgressBar.new Comment.count
    Comment.find_each do |comment|
      bar.increment!
      comment.delay.save
    end
  end

  def down
    remove_column :comments, :slug, :string
  end
end
