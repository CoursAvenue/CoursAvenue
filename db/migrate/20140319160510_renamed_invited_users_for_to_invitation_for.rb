class RenamedInvitedUsersForToInvitationFor < ActiveRecord::Migration
  def change
    rename_column :invited_users, :for, :invitation_for
  end
end
