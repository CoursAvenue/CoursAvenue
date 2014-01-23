class RenameInvitedTeachersAndCreateSti < ActiveRecord::Migration
  def change
    rename_table :invited_teachers, :invited_users

    add_column :invited_users, :type, :string
    rename_column :invited_users, :structure_id, :referrer_id

    InvitedUser.all.each do |invited_user|
      invited_user.update_column :type, 'InvitedUser::Teacher'
    end
  end
end
