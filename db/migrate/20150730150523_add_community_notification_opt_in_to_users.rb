class AddCommunityNotificationOptInToUsers < ActiveRecord::Migration
  def change
    add_column :users, :community_notification_opt_in, :boolean, default: true
  end
end
