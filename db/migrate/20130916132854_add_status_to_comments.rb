class AddStatusToComments < ActiveRecord::Migration
  def change
    add_column :comments, :status, :string
    Comment.all.each do |comment|
      comment.update_column :status, 'accepted'
    end
  end
end
