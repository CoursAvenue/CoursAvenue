class AddEmailStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_status, :string
    add_column :users, :last_email_sent_at, :string
    add_column :users, :last_email_sent_status, :string
  end
end
