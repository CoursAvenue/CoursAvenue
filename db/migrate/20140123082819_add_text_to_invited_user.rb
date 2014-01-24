class AddTextToInvitedUser < ActiveRecord::Migration
  def change
    add_column :invited_users, :email_text, :text
  end
end
