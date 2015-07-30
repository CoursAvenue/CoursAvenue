class AddDeletedAtToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :deleted_at, :datetime
    add_column :community_memberships, :deleted_at, :datetime
    add_column :community_message_threads, :deleted_at, :datetime
  end
end
