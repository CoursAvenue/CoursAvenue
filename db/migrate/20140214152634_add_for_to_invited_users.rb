class AddForToInvitedUsers < ActiveRecord::Migration
  def change
    add_column :invited_users, :for, :string
  end
end
