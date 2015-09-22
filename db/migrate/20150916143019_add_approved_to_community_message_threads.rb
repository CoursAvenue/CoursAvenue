class AddApprovedToCommunityMessageThreads < ActiveRecord::Migration
  def change
    add_column :community_message_threads, :approved, :boolean, default: false
  end
end
