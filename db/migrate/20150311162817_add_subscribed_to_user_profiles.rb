class AddSubscribedToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :subscribed, :boolean, default: true
  end
end
