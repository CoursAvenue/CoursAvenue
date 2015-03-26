class AcceptAllPendingComments < ActiveRecord::Migration
  def change
    Comment.where(status: 'pending').update_all status: 'accepted'
  end
end
