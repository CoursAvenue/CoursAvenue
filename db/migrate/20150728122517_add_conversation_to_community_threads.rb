class AddConversationToCommunityThreads < ActiveRecord::Migration
  def change
    add_reference :community_threads, :mailboxer_conversation, index: true
  end
end
