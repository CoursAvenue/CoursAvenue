class CreateCommunityMemberships < ActiveRecord::Migration
  def change
    create_table :community_memberships do |t|
      t.references :user, index: true
      t.references :community, index: true
      t.datetime :last_notification_at

      t.timestamps
    end
  end
end
