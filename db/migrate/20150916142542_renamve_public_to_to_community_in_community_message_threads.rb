class RenamvePublicToToCommunityInCommunityMessageThreads < ActiveRecord::Migration
  def change
    rename_column :community_message_threads, :public, :to_community
  end
end
