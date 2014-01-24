class AddReferrerTypeToInvitedUsers < ActiveRecord::Migration
  def change
    add_column :invited_users, :referrer_type, :string

    InvitedUser.find_each do |invited_user|
      invited_user.update_column :referrer_type, 'Structure'
    end
  end
end
