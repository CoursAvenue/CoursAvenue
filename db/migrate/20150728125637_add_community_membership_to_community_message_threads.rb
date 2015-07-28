class AddCommunityMembershipToCommunityMessageThreads < ActiveRecord::Migration
  def change
    add_reference :community_message_threads, :community_membership, index: true
  end
end
