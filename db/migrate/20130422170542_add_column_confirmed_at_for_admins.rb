class AddColumnConfirmedAtForAdmins < ActiveRecord::Migration
  def up
    add_column :admins, :confirmation_token,   :string
    add_column :admins, :confirmed_at,         :datetime
    add_column :admins, :confirmation_sent_at, :datetime
  end

  def down
    remove_column :admins, :confirmation_token
    remove_column :admins, :confirmed_at
    remove_column :admins, :confirmation_sent_at
  end
end
