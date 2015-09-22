class RemoveToCommunityFromCommunityMessageThreads < ActiveRecord::Migration
  def change
    remove_column :community_message_threads, :to_community
  end
end
