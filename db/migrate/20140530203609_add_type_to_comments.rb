class AddTypeToComments < ActiveRecord::Migration
  def change
    add_column :comments, :type, :string
    Comment.update_all type: 'Comment::Review'
  end
end
