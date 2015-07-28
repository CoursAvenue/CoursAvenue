class RenameCommunityThreadsToCommunityMessageThreads < ActiveRecord::Migration
  def change
    rename_table :community_threads, :community_message_threads
  end
end
