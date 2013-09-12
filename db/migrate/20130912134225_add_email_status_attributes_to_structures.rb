class AddEmailStatusAttributesToStructures < ActiveRecord::Migration
  def change
    add_column :structures, :email_status, :string
    add_column :structures, :last_email_sent_at, :datetime
    add_column :structures, :last_email_sent_status, :string
  end
end
