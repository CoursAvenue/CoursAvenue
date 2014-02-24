class AddMetaDataToInvitedUsers < ActiveRecord::Migration
  def change
    add_column :invited_users, :meta_data, :hstore
  end
end
