class AddIndexableCardIdToCommunityMessageThreads < ActiveRecord::Migration
  def change
    add_column :community_message_threads, :indexable_card_id, :integer
    add_index :community_message_threads, :indexable_card_id
  end
end
