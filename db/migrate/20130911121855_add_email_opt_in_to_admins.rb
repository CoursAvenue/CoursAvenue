class AddEmailOptInToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :email_opt_in, :boolean, default: true
  end
end
