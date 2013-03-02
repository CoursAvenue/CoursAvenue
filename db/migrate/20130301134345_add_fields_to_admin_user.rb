class AddFieldsToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :civility, :string
    add_column :admin_users, :firstname, :string
    add_column :admin_users, :lastname, :string
    add_column :admin_users, :phone_number, :string
    add_column :admin_users, :mobile_phone_number, :string
    add_column :admin_users, :activated, :boolean, default: false
  end
end
